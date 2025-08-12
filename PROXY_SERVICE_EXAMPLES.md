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

# Có thể truy cập proxy service thông qua job service
class TiktokJob(BaseJob):
    def perform_job(self, account):
        # Nếu gặp lỗi IP bị block, có thể reset IP
        try:
            # Thực hiện job bình thường...
            result = self._perform_follow_job(link)
            
            if result == 2:  # Lỗi có thể do IP bị block
                self.logger.info("Job thất bại, thử reset IP và làm lại")
                
                # Reset IP thông qua job service (nếu có reference)
                if hasattr(self, 'job_service') and self.job_service:
                    reset_success = self.job_service.reset_current_proxy_ip()
                    if reset_success:
                        self.logger.info("Đã reset IP thành công, thử job lại")
                        # Chờ một chút để IP mới có hiệu lực
                        self.safe_sleep(5)
                        # Thử lại job
                        result = self._perform_follow_job(link)
                    
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

## 4. Các trường hợp sử dụng thực tế

# A. Reset IP khi gặp lỗi rate limit
if job_result == 3:  # Rate limit or blocked
    self.logger.warning("Có thể bị rate limit, reset IP")
    self.job_service.reset_current_proxy_ip()
    self.safe_sleep(10)  # Chờ IP mới
    
# B. Reset IP định kỳ mỗi 10 job
self.job_count += 1
if self.job_count % 10 == 0:
    self.logger.info("Reset IP định kỳ sau 10 job")
    self.job_service.reset_current_proxy_ip()

# C. Reset IP khi chuyển tài khoản
def switch_to_account(self, account):
    success = super().switch_to_account(account)
    if success:
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
