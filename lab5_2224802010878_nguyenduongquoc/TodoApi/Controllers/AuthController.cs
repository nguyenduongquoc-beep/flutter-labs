using Microsoft.AspNetCore.Mvc;
using TodoApi.DTOs;
using TodoApi.Services;

namespace TodoApi.Controllers
{
    /// <summary>
    /// Handles POST /api/auth/register and POST /api/auth/login.
    /// Returns JWT token on successful login.
    /// </summary>
    [ApiController]
    [Route("api/auth")]
    public class AuthController : ControllerBase
    {
        private readonly AuthService _authService;

        public AuthController(AuthService authService)
        {
            _authService = authService;
        }

        // POST /api/auth/register
        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] RegisterDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) ||
                string.IsNullOrWhiteSpace(dto.Password))
                return BadRequest(new { message = "Email và mật khẩu không được để trống." });

            var (success, message) = await _authService.RegisterAsync(dto);
            if (!success)
                return BadRequest(new { message });

            return Ok(new { message });
        }

        // POST /api/auth/login
        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (string.IsNullOrWhiteSpace(dto.Email) ||
                string.IsNullOrWhiteSpace(dto.Password))
                return BadRequest(new { message = "Email và mật khẩu không được để trống." });

            var (success, message, data) = await _authService.LoginAsync(dto);
            if (!success)
                return Unauthorized(new { message });

            return Ok(data);
        }
    }
}
