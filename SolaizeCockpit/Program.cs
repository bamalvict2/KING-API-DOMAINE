using SolaizeCockpit.Components;
using SolaizeCockpit.Services;

var builder = WebApplication.CreateBuilder(args);

builder.WebHost.UseUrls("http://0.0.0.0:80");

// Razor Components
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

// HttpClient nommé pour l'API (utilise le même host que ton docker-compose)
builder.Services.AddHttpClient("SolaizeApi", client =>
{
    client.BaseAddress = new Uri("http://solaize-api:8080/");
});

// Fournir un HttpClient "par défaut" via la factory (scoped)
builder.Services.AddScoped(sp =>
    sp.GetRequiredService<IHttpClientFactory>().CreateClient("SolaizeApi"));

// Enregistrement des services du Cockpit
builder.Services.AddScoped<ItemsService>();   // service qui utilise HttpClient
builder.Services.AddScoped<UploadService>();

var app = builder.Build();

// Pipeline
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

// NOTE: Ne pas appeler UseAntiforgery() — ce middleware n'existe pas.
// Si tu veux l'antiforgery, configure-le via services.AddAntiforgery(...) et utilisez les helpers côté formulaire.

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();