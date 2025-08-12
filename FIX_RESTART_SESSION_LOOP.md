# Fix: Vòng lặp mở Instagram liên tục khi restart session từ server

## Vấn đề đã phát hiện:
Khi server gửi yêu cầu đồng bộ config và JobService đặt flag `force_restart_session = True`, các job handler (InstagramJob/TikTokJob) vẫn tiếp tục chạy trong các vòng lặp và không biết được cần dừng lại.

## Nguyên nhân:
1. JobService có `safe_sleep()` method riêng có thể return `False` khi cần restart session
2. JobService inject method này vào job handlers qua `set_sleep_function()`
3. Nhưng job handlers gọi `safe_sleep()` mà không kiểm tra return value
4. Khi `force_restart_session = True`, `safe_sleep()` return `False` nhưng job handlers ignore và tiếp tục chạy

## Các file đã sửa:

### 1. jobs/instagram_job.py
**Method: ensure_home_screen()**
- Thêm kiểm tra return value của `safe_sleep(2)` và `safe_sleep(5)`
- Return `False` ngay lập tức khi nhận được yêu cầu dừng

**Method: back_to_home()**
- Thêm kiểm tra return value cho tất cả các lần gọi `safe_sleep()`
- Return `False` ngay lập tức khi nhận được yêu cầu dừng trong vòng lặp

**Method: validate_app_not_banned()**  
- Thêm kiểm tra return value cho `safe_sleep(2)` và `safe_sleep(3)`
- Return `False` ngay lập tức khi nhận được yêu cầu dừng

**Method: switch_to_account()**
- Thêm kiểm tra return value cho `safe_sleep(5)`
- Return `False` ngay lập tức khi nhận được yêu cầu dừng

### 2. jobs/tiktok_job.py
**Method: switch_to_account()**
- Thêm kiểm tra return value cho `safe_sleep(6)`
- Return `False` ngay lập tức khi nhận được yêu cầu dừng

## Kết quả mong đợi:
- Khi server gửi config update với flag restart session
- JobService sẽ set `force_restart_session = True`
- `safe_sleep()` sẽ return `False` 
- Job handlers sẽ nhận được signal và dừng ngay lập tức
- Không còn tình trạng mở Instagram liên tục trong vòng lặp

## Fix bổ sung: Register proxy logic
**Vấn đề phát hiện thêm:** Logic register proxy bị thiếu trong method `run()`

**Thay đổi trong services/job_service.py:**
```python
# Bắt đầu phiên làm việc với danh sách tài khoản đã sẵn sàng
# Đăng ký proxy nếu được bật
use_proxy = self.db.get("use_proxy", False)
if use_proxy:
    if not self.proxy_service.is_proxy_active():
        logger.info("Đăng ký proxy trước khi bắt đầu phiên làm việc")
        proxy_success = self.proxy_service.register_proxy()
        if not proxy_success:
            logger.error("Không thể đăng ký proxy, bỏ qua phiên làm việc này")
            self._start_session_cooldown()
            continue
    else:
        logger.info("Proxy đã được đăng ký, tiếp tục phiên làm việc")
        
self._work_session(all_workable_accounts)
```

**Logic hoàn chỉnh:**
1. **Trước phiên**: Kiểm tra và register proxy nếu cần
2. **Trong phiên**: Sử dụng proxy để làm job + update timestamp
3. **Sau phiên**: Unregister proxy và bắt đầu session cooldown

## Test case:
1. Server gửi yêu cầu sync config 
2. JobService nhận được và set flag restart session
3. InstagramJob đang trong quá trình `ensure_home_screen()` hoặc `back_to_home()`
4. `safe_sleep()` return `False` và method return `False` ngay lập tức
5. `_work_account_session()` nhận được `False` và thoát để restart session

## Log messages mới:
- "Nhận được yêu cầu dừng trong quá trình ensure_home_screen"
- "Nhận được yêu cầu dừng trong quá trình back_to_home" 
- "Nhận được yêu cầu dừng trong validate_app_not_banned"
- "Nhận được yêu cầu dừng trong switch_to_account"
