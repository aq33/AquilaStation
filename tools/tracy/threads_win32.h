/* Minimal C11 <threads.h> for mingw (zig cc -target x86-windows-gnu), which ships without one.
 * Covers only what byond-tracy's prof.c uses: mutex, condition variable, thread create/join.
 * Build: zig cc -target x86-windows-gnu -std=c11 -shared -O2 -DNDEBUG -I<folder with this file as threads.h> prof.c -lws2_32 -o prof.dll
 */
#ifndef AQUILA_THREADS_WIN32_H
#define AQUILA_THREADS_WIN32_H

#include <windows.h>
#include <time.h>

enum { thrd_success = 0, thrd_error = 1, thrd_timedout = 2, thrd_busy = 3, thrd_nomem = 4 };
enum { mtx_plain = 0 };

typedef SRWLOCK mtx_t;
typedef CONDITION_VARIABLE cnd_t;
typedef HANDLE thrd_t;
typedef int (*thrd_start_t)(void *);

static inline int mtx_init(mtx_t *m, int type) { (void)type; InitializeSRWLock(m); return thrd_success; }
static inline void mtx_destroy(mtx_t *m) { (void)m; }
static inline int mtx_lock(mtx_t *m) { AcquireSRWLockExclusive(m); return thrd_success; }
static inline int mtx_unlock(mtx_t *m) { ReleaseSRWLockExclusive(m); return thrd_success; }

static inline int cnd_init(cnd_t *c) { InitializeConditionVariable(c); return thrd_success; }
static inline void cnd_destroy(cnd_t *c) { (void)c; }
static inline int cnd_broadcast(cnd_t *c) { WakeAllConditionVariable(c); return thrd_success; }
static inline int cnd_signal(cnd_t *c) { WakeConditionVariable(c); return thrd_success; }
static inline int cnd_wait(cnd_t *c, mtx_t *m) {
	return SleepConditionVariableSRW(c, m, INFINITE, 0) ? thrd_success : thrd_error;
}
static inline int cnd_timedwait(cnd_t *c, mtx_t *m, const struct timespec *abs) {
	struct timespec now;
	timespec_get(&now, TIME_UTC);
	long long ms = (long long)(abs->tv_sec - now.tv_sec) * 1000 + (abs->tv_nsec - now.tv_nsec) / 1000000;
	if (ms < 0)
		ms = 0;
	if (SleepConditionVariableSRW(c, m, (DWORD)ms, 0))
		return thrd_success;
	return GetLastError() == ERROR_TIMEOUT ? thrd_timedout : thrd_error;
}

struct aquila_thrd_start { thrd_start_t func; void *arg; };

static DWORD WINAPI aquila_thrd_trampoline(LPVOID p) {
	struct aquila_thrd_start start = *(struct aquila_thrd_start *)p;
	HeapFree(GetProcessHeap(), 0, p);
	return (DWORD)start.func(start.arg);
}

static inline int thrd_create(thrd_t *t, thrd_start_t func, void *arg) {
	struct aquila_thrd_start *start = HeapAlloc(GetProcessHeap(), 0, sizeof(*start));
	if (!start)
		return thrd_nomem;
	start->func = func;
	start->arg = arg;
	*t = CreateThread(NULL, 0, aquila_thrd_trampoline, start, 0, NULL);
	if (!*t) {
		HeapFree(GetProcessHeap(), 0, start);
		return thrd_error;
	}
	return thrd_success;
}

static inline int thrd_join(thrd_t t, int *res) {
	if (WaitForSingleObject(t, INFINITE) != WAIT_OBJECT_0)
		return thrd_error;
	DWORD code = 0;
	GetExitCodeThread(t, &code);
	CloseHandle(t);
	if (res)
		*res = (int)code;
	return thrd_success;
}

#endif
