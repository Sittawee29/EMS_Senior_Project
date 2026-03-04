import requests
import time
import redis
import json
import matplotlib.pyplot as plt

# ตั้งค่า URL และ Redis
API_URL = "http://127.0.0.1:8000/api/test-redis-volume"
REDIS_HOST = "127.0.0.1"
REDIS_PORT = 6379

# จำลองจำนวนตัวแปร: 1000 (5 Plants), 2000 (10 Plants), ไปเรื่อยๆ
volume_sizes = [1000, 2000, 5000, 10000, 20000]
response_times = []

# เชื่อมต่อ Redis สำหรับสร้าง Data จำลอง
try:
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    r.ping()
except redis.ConnectionError:
    print("Error: Cannot connect to Redis. Please ensure Redis is running on the specified host and port.")
    exit()

print("Starting Volume Testing with Redis...")

for volume in volume_sizes:
    # 1. เตรียมข้อมูลลง Redis ให้พร้อมก่อน (เสมือนว่าเซนเซอร์ส่งค่ามารอไว้แล้ว)
    pipe = r.pipeline()
    dummy_payload = json.dumps({"value": 25.5, "status": "online", "plant": "Plant_X"})
    for i in range(volume):
        pipe.set(f"dummy_sensor:{i}", dummy_payload)
    pipe.execute()
    
    time.sleep(0.5) # รอให้ Data นิ่งแป๊บนึง
    
    # 2. ยิง API และจับเวลาแบบแม่นยำ
    target_url = f"{API_URL}?size={volume}"
    start_time = time.perf_counter()
    try:
        response = requests.get(target_url)
        end_time = time.perf_counter()
        
        # คำนวณเวลาและขนาดไฟล์ (KB)
        time_taken_ms = (end_time - start_time) * 1000
        payload_size_kb = len(response.content) / 1024
        
        response_times.append(time_taken_ms)
        print(f"   - Volume: {volume} vars | Time: {time_taken_ms:.2f} ms | Payload Size: {payload_size_kb:.2f} KB")
        
    except Exception as e:
        print(f"Error {volume}: {e}")

    # 3. ลบข้อมูลทิ้งเพื่อเตรียมเทสรอบต่อไป
    keys_to_delete = r.keys("dummy_sensor:*")
    if keys_to_delete:
        # ใช้ pipeline ลบทีละกลุ่มเพื่อไม่ให้ Redis ค้าง
        pipe = r.pipeline()
        for i in range(0, len(keys_to_delete), 5000):
            pipe.delete(*keys_to_delete[i:i+5000])
        pipe.execute()

# --- วาดกราฟ ---
plt.figure(figsize=(10, 6))
plt.plot(volume_sizes, response_times, marker='o', linestyle='-', color='red', linewidth=2)

for x, y in zip(volume_sizes, response_times):
    plt.annotate(f"{y:.1f} ms", (x, y), textcoords="offset points", xytext=(0, 10), ha='center', fontsize=9)

plt.title('Real Redis Volume Testing\n(API + Redis MGET Performance)')
plt.xlabel('Volume Size (Number of Variables from Redis)')
plt.ylabel('Total Response Time (ms)')
plt.grid(True, linestyle='--', alpha=0.7)
plt.ylim(0, max(response_times) * 1.5 if response_times else 100)

plt.savefig("volume_testing_result.png")
print("\nVolume Testing Completed! Saved as volume_testing_result.png")
plt.show()