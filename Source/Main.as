bool g_visible = true;
float g_dt = 0;
Dashboard@ g_dashboard;

nvg::Font g_font;
nvg::Font g_fontBold;

void RenderMenu()
{
	if (UI::MenuItem("\\$9f3" + Icons::BarChart + "\\$z Dashboard", "", g_visible)) {
		g_visible = !g_visible;
	}
}

void Render()
{
	if (!g_visible) {
		return;
	}

	// Render dashboard
	if (g_dashboard !is null) {
		g_dashboard.Render();
	}
}

void Update(float dt)
{
	// We need to save this for the Accelerometer:
	// Specifically to get an accurate acceleration value in meters per second per second.
	// Without this dt we can only get a fake 'acceleration' that doesn't incorporate time properly.
	g_dt = dt;
}

void OnSettingsChanged()
{
	g_dashboard.OnSettingsChanged();
}

void Main()
{
	g_font = nvg::LoadFont("DroidSans.ttf", true);
	g_fontBold = nvg::LoadFont("DroidSans-Bold.ttf", true);

	@g_dashboard = Dashboard();
	g_dashboard.Main();
}

/** Called whenever a mouse button is pressed. `x` and `y` are the viewport coordinates.
*/
UI::InputBlocking OnMouseButton(bool down, int button, int x, int y) {
	g_dashboard.OnMouseButton(down, button, x, y);
	return UI::InputBlocking::DoNothing;
}