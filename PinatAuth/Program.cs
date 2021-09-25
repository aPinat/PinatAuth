using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var httpClient = new HttpClient();

var clientId = Environment.GetEnvironmentVariable("CLIENT_ID") ?? throw new ApplicationException("CLIENT_ID missing.");
var clientSecret = Environment.GetEnvironmentVariable("CLIENT_SECRET") ?? throw new ApplicationException("CLIENT_SECRET missing.");
var oAuthBaseUrl = Environment.GetEnvironmentVariable("OAUTH_BASE_URL") ?? throw new ApplicationException("OAUTH_BASE_URL missing.");
var applicationBaseUrl = Environment.GetEnvironmentVariable("APPLICATION_BASE_URL") ?? throw new ApplicationException("APPLICATION_BASE_URL missing.");
var domain = Environment.GetEnvironmentVariable("DOMAIN") ?? throw new ApplicationException("DOMAIN missing.");

app.MapGet("/login", async context =>
{
    if (!context.Request.Query.ContainsKey("code"))
    {
        if (context.Request.Query.ContainsKey("redirect_url")) context.Response.Cookies.Append("PinatAuthRedirect", context.Request.Query["redirect_url"]);
        context.Response.Redirect($"{oAuthBaseUrl}/oauth2/authorize?client_id={clientId}&response_type=code&redirect_uri={applicationBaseUrl}/login");
    }
    else
    {
        var message = await httpClient.PostAsync($"{oAuthBaseUrl}/oauth2/token",
            new FormUrlEncodedContent(new Dictionary<string, string>
            {
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "code", context.Request.Query["code"] },
                { "grant_type", "authorization_code" },
                { "redirect_uri", $"{applicationBaseUrl}/login" }
            }));
        if (message.IsSuccessStatusCode)
        {
            var oAuthTokenResponse = await message.Content.ReadFromJsonAsync<JsonDocument>();
            if (oAuthTokenResponse != null)
            {
                Console.WriteLine(oAuthTokenResponse.RootElement.GetProperty("access_token").GetString());
                context.Response.Cookies.Append("access_token", oAuthTokenResponse.RootElement.GetProperty("access_token").GetString() ?? string.Empty,
                    new CookieOptions { Domain = domain, HttpOnly = true, Secure = true });
            }

            var redirect = context.Request.Cookies["PinatAuthRedirect"];
            if (redirect != null)
            {
                context.Response.Cookies.Delete("PinatAuthRedirect");
                context.Response.Redirect(redirect);
            }
            else context.Response.Redirect(applicationBaseUrl);
        }
        else
        {
            context.Response.StatusCode = (int)message.StatusCode;
            await context.Response.WriteAsync(await message.Content.ReadAsStringAsync());
        }
    }
});

app.MapGet("/logout", context =>
{
    context.Response.Cookies.Delete("access_token", new CookieOptions { Domain = domain, HttpOnly = true });
    context.Response.Redirect($"{oAuthBaseUrl}/oauth2/logout?client_id={clientId}&post_logout_redirect_uri={applicationBaseUrl}/login");
    return Task.CompletedTask;
});

app.Run();