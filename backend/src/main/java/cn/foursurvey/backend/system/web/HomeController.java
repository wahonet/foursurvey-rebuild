package cn.foursurvey.backend.system.web;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HomeController {

    @GetMapping(value = "/", produces = MediaType.TEXT_HTML_VALUE + ";charset=UTF-8")
    public String home() {
        return """
                <!doctype html>
                <html lang="zh-CN">
                <head>
                  <meta charset="UTF-8">
                  <meta name="viewport" content="width=device-width, initial-scale=1.0">
                  <title>FS Backend</title>
                  <style>
                    body {
                      margin: 0;
                      font-family: "Microsoft YaHei", "PingFang SC", sans-serif;
                      background: #f3f6fb;
                      color: #1f2937;
                    }
                    .page {
                      min-height: 100vh;
                      display: grid;
                      place-items: center;
                      padding: 24px;
                    }
                    .card {
                      width: min(720px, 100%);
                      background: #ffffff;
                      border: 1px solid #dbe4f0;
                      border-radius: 10px;
                      padding: 28px 32px;
                      box-shadow: 0 14px 36px rgba(16, 59, 115, 0.08);
                    }
                    h1 {
                      margin: 0 0 12px;
                      font-size: 28px;
                      color: #0f4c97;
                    }
                    p {
                      margin: 0 0 14px;
                      line-height: 1.7;
                      color: #4b5563;
                    }
                    ul {
                      margin: 18px 0 0;
                      padding-left: 20px;
                    }
                    li {
                      margin: 8px 0;
                    }
                    a {
                      color: #0f62c9;
                      text-decoration: none;
                    }
                    a:hover {
                      text-decoration: underline;
                    }
                    .tag {
                      display: inline-flex;
                      align-items: center;
                      min-height: 28px;
                      padding: 0 10px;
                      border-radius: 999px;
                      background: #e8f0fb;
                      color: #0f4c97;
                      font-size: 12px;
                      font-weight: 700;
                    }
                  </style>
                </head>
                <body>
                  <main class="page">
                    <section class="card">
                      <span class="tag">FS Backend Running</span>
                      <h1>后端服务已启动</h1>
                      <p>这里是重建版后端服务入口，不再返回静态资源异常。</p>
                      <p>如果你是从浏览器直接打开这个地址，前端页面请访问本机前端地址；如果你在联调接口，可以继续使用 API 路径。</p>
                      <ul>
                        <li>前端工作台：<a href="http://127.0.0.1:5173">http://127.0.0.1:5173</a></li>
                        <li>工程引导接口：<a href="/api/system/bootstrap">/api/system/bootstrap</a></li>
                        <li>健康检查：<a href="/actuator/health">/actuator/health</a></li>
                      </ul>
                    </section>
                  </main>
                </body>
                </html>
                """;
    }
}
