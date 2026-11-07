import sys, time, numpy as np, soundfile as sf, pyaudiowpatch as pa

secs = float(sys.argv[1]); out = sys.argv[2]
a = pa.PyAudio()
d = a.get_default_wasapi_loopback()
ch = d['maxInputChannels']; sr = int(d['defaultSampleRate'])
frames = []
st = a.open(format=pa.paFloat32, channels=ch, rate=sr, input=True, input_device_index=d['index'], frames_per_buffer=1024)
print('rec start', time.time(), flush=True)
t = time.time()
while time.time() - t < secs:
    frames.append(np.frombuffer(st.read(1024, exception_on_overflow=False), dtype=np.float32))
st.stop_stream(); st.close(); a.terminate()
data = np.concatenate(frames).reshape(-1, ch)
sf.write(out, data, sr)
print('saved', data.shape, sr)
