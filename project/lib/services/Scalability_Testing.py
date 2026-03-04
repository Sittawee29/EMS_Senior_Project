import requests
import time
import concurrent.futures
import matplotlib.pyplot as plt

API_URL = "http://127.0.0.1:8000/api/dashboard"
concurrent_users_list = [50, 100, 200, 500, 1000]

def run_load_test():
    avg_response_times = []
    for users in concurrent_users_list:
        results = []
        with concurrent.futures.ThreadPoolExecutor(max_workers=users) as executor:
            # ยิง API พร้อมกัน
            req_start_global = time.time()
            futures = [executor.submit(lambda: requests.get(API_URL)) for _ in range(users)]
            for future in concurrent.futures.as_completed(futures):
                try:
                    future.result()
                except:
                    pass
            req_end_global = time.time()
            
        # คิดเวลาเฉลี่ยรวม
        avg_time_ms = ((req_end_global - req_start_global) / users) * 1000
        avg_response_times.append(avg_time_ms)
        print(f"   - Users: {users} | Avg Time: {avg_time_ms:.2f} ms")
    return avg_response_times

print("Phase 1: Scalability Testing")
times_before_scale = run_load_test()

print("\nPlease scale up the server (e.g., using: uvicorn API_server:app --workers 4)")
print("(Make sure to stop the current server and restart it with the new worker count before proceeding.)")
input("Press Enter when the new server is ready...")

print("\nPhase 2: Scalability Testing After Scaling")
times_after_scale = run_load_test()

# --- วาดกราฟเปรียบเทียบ Scalability ---
plt.figure(figsize=(10, 6))

# เส้นที่ 1 (ก่อน Scale) สีแดง
plt.plot(concurrent_users_list, times_before_scale, marker='o', linestyle='-', color='red', linewidth=2, label='Before Scale (1 Worker)')
for x, y in zip(concurrent_users_list, times_before_scale):
    plt.annotate(f"{y:.1f}", (x, y), textcoords="offset points", xytext=(0, 10), ha='center', color='red', fontsize=9)

# เส้นที่ 2 (หลัง Scale) สีน้ำเงิน
plt.plot(concurrent_users_list, times_after_scale, marker='^', linestyle='-', color='blue', linewidth=2, label='After Scale (4 Workers)')
for x, y in zip(concurrent_users_list, times_after_scale):
    plt.annotate(f"{y:.1f}", (x, y), textcoords="offset points", xytext=(0, -15), ha='center', color='blue', fontsize=9)

plt.title('Scalability Testing Result\n(Performance Comparison: 1 Worker vs 4 Workers)')
plt.xlabel('Concurrent Users')
plt.ylabel('Average Response Time (ms)')
plt.grid(True, linestyle='--', alpha=0.7)
plt.legend() # แสดงคำอธิบายเส้นกราฟ
plt.ylim(0, max(max(times_before_scale), max(times_after_scale)) * 1.3)

plt.savefig("scalability_testing_result.png")
print("\nScalability Testing Completed! Saved as scalability_testing_result.png")
plt.show()