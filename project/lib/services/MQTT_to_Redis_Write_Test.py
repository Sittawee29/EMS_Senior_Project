import redis
import time

# ตั้งค่า Redis
REDIS_HOST = "127.0.0.1"
REDIS_PORT = 6379

try:
    r = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
    r.ping()
except redis.ConnectionError:
    print("Error: Cannot connect to Redis. Please ensure Redis is running on the specified host and port.")
    exit()

# จำลองจำนวน Message ที่ทะลักเข้ามาจาก MQTT
TOTAL_MESSAGES = 10000

print(f"Starting Write Throughput Test (Simulating MQTT Sending {TOTAL_MESSAGES} Messages)")
print("-" * 50)

# =========================================================
# การทดสอบที่ 1: เขียนทีละ Message (แบบที่ Worker ทั่วไปทำ)
# จำลองสถานการณ์: on_message ทำงานและสั่ง r.set() ทีละบรรทัด
# =========================================================
print("Testing Scenario 1: Single Writes (Simulating Worker Writing Each Message Individually)")
start_time = time.perf_counter()

for i in range(TOTAL_MESSAGES):
    # จำลองการเขียนทับค่า (Overwrite) ใน Redis
    r.set(f"plant1_sensor:{i}", 25.5 + (i * 0.01))

end_time = time.perf_counter()
time_taken = end_time - start_time
ops = TOTAL_MESSAGES / time_taken # คำนวณหา Operations Per Second (การเขียนต่อวินาที)

print(f"Used Time: {time_taken:.4f} seconds")
print(f"Speed: {ops:.0f} messages/second (Writes per second)")
print("-" * 50)

# =========================================================
# การทดสอบที่ 2: เขียนแบบ Pipeline (แบบ Optimized)
# จำลองสถานการณ์: Worker เก็บข้อมูลใส่ตะกร้า แล้วโยนโครมเดียวลง Redis
# =========================================================
print("Testing Scenario 2: Pipeline Write (Batching Writes)")
start_time = time.perf_counter()

pipe = r.pipeline()
for i in range(TOTAL_MESSAGES):
    pipe.set(f"plant1_sensor:{i}", 30.0 + (i * 0.01))
pipe.execute() # สั่งรันทีเดียวทั้งหมด 10,000 คำสั่ง

end_time = time.perf_counter()
time_taken_pipe = end_time - start_time
ops_pipe = TOTAL_MESSAGES / time_taken_pipe

print(f"Used Time: {time_taken_pipe:.4f} seconds")
print(f"Speed: {ops_pipe:.0f} messages/second (Writes per second)")
print("-" * 50)

# สรุปผล
speedup = ops_pipe / ops
print(f"Summary: Using Pipeline improved write speed by {speedup:.1f}x!")