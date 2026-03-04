import requests
import time
import concurrent.futures
import matplotlib.pyplot as plt

API_URL = "http://127.0.0.1:8000/api/dashboard"

concurrent_users_list = [10, 50, 100, 200, 500, 1000]
avg_response_times = []

print("Starting Load Testing (Concurrent Users)...")

def fetch_api():
    req_start = time.time()
    try:
        requests.get(API_URL)
    except requests.exceptions.RequestException:
        pass
    req_end = time.time()
    return req_end - req_start

for users in concurrent_users_list:
    results = []
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=users) as executor:
        futures = [executor.submit(fetch_api) for _ in range(users)]
        for future in concurrent.futures.as_completed(futures):
            results.append(future.result())
            
    avg_time_ms = (sum(results) / len(results)) * 1000
    avg_response_times.append(avg_time_ms)
    
    print(f"Concurrent Users: {users} Avg Response Time = {avg_time_ms:.2f} ms")

# --- วาดกราฟ Load Testing ---
plt.figure(figsize=(10, 6))
plt.plot(concurrent_users_list, avg_response_times, marker='o', linestyle='-', color='r', linewidth=2)

for x, y in zip(concurrent_users_list, avg_response_times):
    # ใช้ plt.annotate เพื่อแสดงข้อความและเลื่อนตำแหน่งได้ง่าย
    plt.annotate(f"({x}, {y:.1f})",      # รูปแบบข้อความที่จะโชว์ เช่น (100, 118.0)
                 (x, y),                 # พิกัดของจุดที่จะเอาข้อความไปวาง
                 textcoords="offset points", # อ้างอิงการขยับข้อความจากจุดพิกัด
                 xytext=(0, 10),         # ขยับข้อความขึ้นด้านบน (แกน Y) 10 พิกเซล จะได้ไม่ทับเส้น
                 ha='center',            # จัดกึ่งกลางข้อความให้อยู่ตรงกับจุด
                 fontsize=9,             # ขนาดตัวอักษร
                 color='black')          # สีตัวอักษร

plt.title('Load Testing Result\n(Response Time vs Concurrent Users)')
plt.xlabel('Concurrent Users (Threads)')
plt.ylabel('Average Response Time (ms)')
plt.grid(True, linestyle='--', alpha=0.7)
plt.ylim(0, max(avg_response_times) * 1.5 if avg_response_times else 100)

output_filename = "load_testing_result.png"
plt.savefig(output_filename)
print("Load Testing Successfully Completed!")
plt.show()