using System.Text.Json;
using PinatAuth;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var httpClient = new HttpClient();

var clientId = Environment.GetEnvironmentVariable("CLIENT_ID") ?? throw new ApplicationException("CLIENT_ID missing.");
var clientSecret = Environment.GetEnvironmentVariable("CLIENT_SECRET") ?? throw new ApplicationException("CLIENT_SECRET missing.");
var oAuthBaseUrl = Environment.GetEnvironmentVariable("OAUTH_BASE_URL") ?? throw new ApplicationException("OAUTH_BASE_URL missing.");
var applicationBaseUrl = Environment.GetEnvironmentVariable("APPLICATION_BASE_URL") ?? throw new ApplicationException("APPLICATION_BASE_URL missing.");
var domain = Environment.GetEnvironmentVariable("DOMAIN") ?? throw new ApplicationException("DOMAIN missing.");
var useRefreshToken = bool.Parse(Environment.GetEnvironmentVariable("USE_REFRESH_TOKEN") ?? "false");

var redirectUri = $"{applicationBaseUrl}/login";

var response = await httpClient.GetAsync($"{oAuthBaseUrl}/.well-known/openid-configuration");
response.EnsureSuccessStatusCode();
var wellKnown = await response.Content.ReadFromJsonAsync<JsonElement>();
var tokenEndpoint = wellKnown.GetProperty("token_endpoint").GetString();
var authorizationEndpoint = wellKnown.GetProperty("authorization_endpoint").GetString();
var endSessionEndpoint = wellKnown.GetProperty("end_session_endpoint").GetString();

app.MapGet("/login", async context =>
{
    var logger = context.RequestServices.GetRequiredService<ILogger<Program>>();
    if (context.Request.Query.TryGetValue("code", out var code))
    {
        logger.LogInformation("Found authorization_code");
        var tokenResponse = await httpClient.PostAsync(tokenEndpoint,
            new FormUrlEncodedContent(new Dictionary<string, string>
            {
                { "client_id", clientId },
                { "client_secret", clientSecret },
                { "code", code.ToString() },
                { "grant_type", "authorization_code" },
                { "redirect_uri", redirectUri }
            }));


        if (tokenResponse.IsSuccessStatusCode)
        {
            var token = await tokenResponse.Content.ReadFromJsonAsync<TokenResponse>();
            if (token != null)
            {
                context.Response.Cookies.Append("access_token", token.AccessToken,
                    new CookieOptions { Domain = domain, HttpOnly = true, Secure = true });
                if (useRefreshToken && token.RefreshToken != null)
                    context.Response.Cookies.Append("refresh_token", token.RefreshToken,
                        new CookieOptions { Domain = domain, HttpOnly = true, Secure = true, Expires = DateTimeOffset.Now.AddDays(30) });
            }

            if (context.Request.Cookies.TryGetValue("PinatAuthRedirect", out var redirect))
            {
                context.Response.Cookies.Delete("PinatAuthRedirect");
                context.Response.Redirect(redirect!);
            }
            else
            {
                context.Response.Redirect("/");
            }
        }
        else
        {
            context.Response.StatusCode = (int)tokenResponse.StatusCode;
            await context.Response.WriteAsync(await tokenResponse.Content.ReadAsStringAsync());
        }
    }
    else if (useRefreshToken && context.Request.Cookies.TryGetValue("refresh_token", out var refreshToken))
    {
        logger.LogInformation("Found refresh_token");
        var tokenResponse = await httpClient.PostAsync(tokenEndpoint,
            new FormUrlEncodedContent(new Dictionary<string, string>
            {
                { "client_id", clientId }, { "client_secret", clientSecret }, { "grant_type", "refresh_token" }, { "refresh_token", refreshToken! }
            }));
        if (tokenResponse.IsSuccessStatusCode)
        {
            var token = await tokenResponse.Content.ReadFromJsonAsync<TokenResponse>();
            if (token != null)
            {
                context.Response.Cookies.Append("access_token", token.AccessToken,
                    new CookieOptions { Domain = domain, HttpOnly = true, Secure = true });
                if (token.RefreshToken != null)
                    context.Response.Cookies.Append("refresh_token", token.RefreshToken,
                        new CookieOptions { Domain = domain, HttpOnly = true, Secure = true, Expires = DateTimeOffset.Now.AddDays(30) });
            }

            context.Response.Redirect(context.Request.Query.TryGetValue("redirect_url", out var redirectUrl) ? redirectUrl.ToString() : "/");
        }
        else
        {
            context.Response.StatusCode = (int)tokenResponse.StatusCode;
            await context.Response.WriteAsync(await tokenResponse.Content.ReadAsStringAsync());
        }
    }
    else
    {
        if (context.Request.Query.ContainsKey("redirect_url"))
            context.Response.Cookies.Append("PinatAuthRedirect", context.Request.Query["redirect_url"].ToString());

        if (useRefreshToken)
        {
            logger.LogInformation("No code or refresh_token found");
            context.Response.Redirect($"{authorizationEndpoint}?client_id={clientId}&response_type=code&scope=offline_access&redirect_uri={redirectUri}");
        }
        else
        {
            logger.LogInformation("No code found");
            context.Response.Redirect($"{authorizationEndpoint}?client_id={clientId}&response_type=code&redirect_uri={redirectUri}");
        }
    }
});

app.MapGet("/logout", context =>
{
    context.Response.Cookies.Delete("access_token", new CookieOptions { Domain = domain, HttpOnly = true });
    context.Response.Cookies.Delete("refresh_token", new CookieOptions { Domain = domain, HttpOnly = true });
    context.Response.Redirect($"{endSessionEndpoint}?client_id={clientId}&post_logout_redirect_uri={applicationBaseUrl}/login");
    return Task.CompletedTask;
});

app.Run();
