# Example: Cách sử dụng ProxyService và reset IP trong quá trình làm việc

## 1. Trong JobService

# JobService tự động quản lý proxy thông qua ProxyService
# Có các phương thức tiện lợi để sử dụng trong quá trình làm việc:

# Reset IP cho proxy hiện tại
job_service.reset_current_proxy_ip()

# Lấy thông tin trạng thái proxy
proxy_status = job_service.get_proxy_status()
print(proxy_status)  # "Đang sử dụng proxy: to_pppoe2"

# Lấy thông tin chi tiết proxy
proxy_info = job_service.get_proxy_info()
print(proxy_info)
# {
#     "proxy_id": None,
#     "proxy_name": "to_pppoe2", 
#     "proxy_table": "to_pppoe2",
#     "last_update": 1691888888,
#     "display_name": "to_pppoe2",
#     "is_active": True
# }

## 2. Trong Job Handlers (TikTok/Instagram Job)

# Job handlers sẽ có proxy_service được set tự động từ JobService
class InstagramJob(BaseJob):
    def validate_app_not_banned(self):
        # Nếu gặp lỗi IP bị block, có thể reset IP
        if page_not_available:
            self.logger.warning("Phát hiện trang không hiển thị, đang reset proxy và làm mới")
            
            # Reset IP thông qua proxy_service
            if self.proxy_service:
                reset_success = self.proxy_service.force_reset_current_ip()
                if reset_success:
                    self.logger.info("Đã reset IP thành công")
                    self.safe_sleep(2)  # Chờ IP mới có hiệu lực
                else:
                    self.logger.error("Reset IP thất bại")
            else:
                self.logger.warning("Proxy service chưa được thiết lập")
    
    def _perform_follow_job(self, profile_link):
        try:
            # Thực hiện job bình thường...
            result = self._attempt_follow(profile_link)
            
            if result == 2:  # Lỗi có thể do IP bị block
                self.logger.info("Job thất bại, thử reset IP và làm lại")
                
                # Reset IP thông qua proxy_service
                if self.proxy_service:
                    reset_success = self.proxy_service.force_reset_current_ip()
                    if reset_success:
                        self.logger.info("Đã reset IP thành công, thử job lại")
                        # Chờ một chút để IP mới có hiệu lực
                        self.safe_sleep(5)
                        # Thử lại job
                        result = self._attempt_follow(profile_link)
                    
            return result
            
        except Exception as e:
            self.logger.error(f"Lỗi job: {e}")
            return 2

## 3. Truy cập trực tiếp ProxyService 

# Nếu cần truy cập trực tiếp ProxyService
from services.proxy_service import ProxyService

# Khởi tạo
proxy_service = ProxyService(db_service, helper_service)

# Đăng ký proxy
success = proxy_service.register_proxy()

# Reset IP
reset_success = proxy_service.reset_ip()

# Hoặc reset IP với table name cụ thể
reset_success = proxy_service.reset_ip("to_pppoe2")

# Bắt buộc reset IP cho proxy hiện tại
force_reset_success = proxy_service.force_reset_current_ip()

# Cập nhật timestamp
proxy_service.update_proxy()

# Giải phóng proxy
proxy_service.unregister_proxy()

# Kiểm tra trạng thái
is_active = proxy_service.is_proxy_active()
status = proxy_service.get_proxy_status()
info = proxy_service.get_proxy_info()

## 4. Cách ProxyService được Inject vào Job Handlers

```python
# Trong JobService, proxy_service sẽ được inject vào mỗi job handler
class JobService:
    def __init__(self):
        self.proxy_service = ProxyService()
        self.job_handlers = {}
        self._init_job_handlers()
    
    def _init_job_handlers(self):
        """Khởi tạo job handlers và inject proxy_service"""
        # TikTok job handler
        if self.config.is_tiktok_job_enabled:
            tiktok_job = TiktokJob(self.logger, self.db_service, self.config, 'tiktok')
            tiktok_job.set_proxy_service(self.proxy_service)  # Inject proxy service
            self.job_handlers['tiktok'] = tiktok_job
        
        # Instagram job handler
        if self.config.is_instagram_job_enabled:
            instagram_job = InstagramJob(self.logger, self.db_service, self.config, 'instagram')  
            instagram_job.set_proxy_service(self.proxy_service)  # Inject proxy service
            self.job_handlers['instagram'] = instagram_job
    
    # Convenience methods để JobService có thể điều khiển proxy
    def reset_current_proxy_ip(self):
        return self.proxy_service.force_reset_current_ip()
    
    def get_proxy_status(self):
        return self.proxy_service.get_proxy_status()
```

## 5. Các trường hợp sử dụng thực tế

# A. Reset IP khi gặp lỗi rate limit
if job_result == 3:  # Rate limit or blocked
    self.logger.warning("Có thể bị rate limit, reset IP")
    if self.proxy_service:
        self.proxy_service.force_reset_current_ip()
        self.safe_sleep(10)  # Chờ IP mới
    
# B. Reset IP định kỳ mỗi 10 job
self.job_count += 1
if self.job_count % 10 == 0:
    self.logger.info("Reset IP định kỳ sau 10 job")
    if self.proxy_service:
        self.proxy_service.force_reset_current_ip()

# C. Reset IP khi chuyển tài khoản
def switch_to_account(self, account):
    success = super().switch_to_account(account)
    if success and self.proxy_service:
        # Reset IP khi chuyển tài khoản để tránh liên kết
        self.logger.info("Chuyển tài khoản thành công, reset IP")
        self.job_service.reset_current_proxy_ip()
        self.safe_sleep(3)
    return success

## 5. Logging và Monitor

# ProxyService tự động log các hoạt động:
# - Đăng ký proxy thành công/thất bại
# - Reset IP thành công/thất bại  
# - Update timestamp
# - Giải phóng proxy
# - Queue status khi proxy server full

# Có thể monitor qua get_proxy_info() để tracking:
proxy_info = job_service.get_proxy_info()
if proxy_info['is_active']:
    print(f"Proxy đang hoạt động: {proxy_info['display_name']}")
    print(f"Cập nhật cuối: {proxy_info['last_update']}")
else:
    print("Không có proxy đang hoạt động")
