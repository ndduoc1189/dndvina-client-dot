# Test Framework cho Social Media Jobs

## Mô tả

Thư mục này chứa các file test để debug nhanh các hàm trong Instagram Job và TikTok Job. Thay vì sử dụng unittest phức tạp, đây là cách đơn giản để gọi trực tiếp các hàm và debug.

## Cấu trúc Files

```
tests/
├── __init__.py                 # Package init
├── main_test.py               # Main test runner (chọn platform)
├── test_instagram_job.py      # Test cho Instagram Job
├── test_tiktok_job.py         # Test cho TikTok Job
└── README.md                  # File này
```

## Cách sử dụng

### 1. Chạy Main Test Runner

```bash
cd d:\auto-dndvina\dndvina-client\tests
python main_test.py
```

Sẽ hiện menu để chọn platform:
- 1: Instagram Job
- 2: TikTok Job

### 2. Chạy riêng từng platform

#### Instagram Job:
```bash
python test_instagram_job.py
```

#### TikTok Job:
```bash
python test_tiktok_job.py
```

## Các hàm có thể test

### Instagram Job

1. **test_post_newfeed()** - Test hàm đăng ảnh
2. **test_execute_job()** - Test thực hiện job (follow/like)
3. **test_get_accounts_from_device()** - Test lấy danh sách tài khoản
4. **test_care_functions()** - Test các hàm care (swipe feed, watch reels, etc.)
5. **test_navigation_functions()** - Test các hàm điều hướng

### TikTok Job

1. **test_get_accounts_from_device()** - Test lấy danh sách tài khoản
2. **test_execute_job()** - Test thực hiện job
3. **test_follow_job()** - Test follow user
4. **test_like_job()** - Test like video
5. **test_navigation_functions()** - Test điều hướng
6. **test_profile_functions()** - Test các hàm profile

## Debug Tips

### 1. Đặt Breakpoint

Mở file test trong VS Code và đặt breakpoint tại dòng gọi hàm:

```python
# Đặt breakpoint ở đây
result = job.post_newfeed(account)
```

### 2. Chạy Debug

- Nhấn F5 hoặc `Debug > Start Debugging`
- Chọn Python file để debug

### 3. Sửa Sample Data

Có thể chỉnh sửa sample data trong các hàm:

```python
def get_sample_account():
    return {
        "id": 1,
        "unique_username": "your_test_username",  # Thay đổi ở đây
        # ...
    }
```

### 4. Test với Data Thực

Nếu muốn test với data thực từ database:

```python
def test_with_real_data():
    job = create_instagram_job()
    
    # Lấy account thực từ DB
    accounts = job.get_accounts_from_device()
    if accounts:
        account = accounts[0]  # Lấy account đầu tiên
        result = job.post_newfeed(account)
```

## Lưu ý

1. **Kết nối thiết bị**: Đảm bảo thiết bị Android đã kết nối và cài đặt app
2. **Quyền truy cập**: App cần quyền truy cập vào hệ thống
3. **Network**: Đảm bảo có kết nối internet để test các API
4. **Database**: Database service cần hoạt động để test các hàm liên quan DB

## Ví dụ sử dụng nhanh

```bash
# 1. Mở terminal tại thư mục tests
cd d:\auto-dndvina\dndvina-client\tests

# 2. Chạy test Instagram
python test_instagram_job.py

# 3. Chọn option 1 để test post_newfeed

# 4. Đặt breakpoint trong VS Code và debug nếu cần
```

## Troubleshooting

### Lỗi Import
```
ImportError: No module named 'jobs.instagram_job'
```
**Giải pháp**: Đảm bảo đang chạy từ thư mục `tests/` và file `__init__.py` tồn tại.

### Lỗi Service
```
❌ Lỗi khi khởi tạo Instagram Job
```
**Giải pháp**: Kiểm tra các service dependencies và database connection.

### Lỗi Thiết bị
```
Device not connected
```
**Giải pháp**: Kết nối lại thiết bị Android và enable USB debugging.
