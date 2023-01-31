class Dashboard
{
	array<DashboardThing@> m_things;
	CSceneVehicleVisState@ visState;

	int visState_length = 0;
	int active_visState;
	bool show_circles = true;
	bool alt_car_selection = false;
	int circle_radius = 20;


	Dashboard()
	{
		m_things.InsertLast(DashboardPadHost());
		m_things.InsertLast(DashboardGearbox());
		m_things.InsertLast(DashboardWheels());
		m_things.InsertLast(DashboardAcceleration());
		m_things.InsertLast(DashboardSpeed());
	}

	void Main()
	{
		while (true) {
			for (uint i = 0; i < m_things.Length; i++) {
				m_things[i].UpdateAsync();
			}
			yield();
		}
	}

	void OnSettingsChanged()
	{
		for (uint i = 0; i < m_things.Length; i++) {
			m_things[i].OnSettingsChanged();
		}
	}

	void Render()
	{
		auto app = GetApp();

		if (Setting_General_HideWhenNotPlaying) {
			if (app.CurrentPlayground !is null && (app.CurrentPlayground.UIConfigs.Length > 0)) {
				if (app.CurrentPlayground.UIConfigs[0].UISequence == CGamePlaygroundUIConfig::EUISequence::Intro) {
					return;
				}
			}
		}


		CSceneVehicleVisState@ visState;

		if (VehicleState::GetAllVis(GetApp().GameScene).Length != visState_length) {
			visState_length = VehicleState::GetAllVis(GetApp().GameScene).Length;
			alt_car_selection = false;
		}

		renderCircles();
		
		if (!alt_car_selection) {
			@visState = @VehicleState::ViewingPlayerState();
		} else {
			@visState = @VehicleState::GetAllVis(GetApp().GameScene)[active_visState].AsyncState;
		}

		if (visState is null) {
			return;
		}

		bool gameUIVisible = UI::IsGameUIVisible();

		for (uint i = 0; i < m_things.Length; i++) {
			auto thing = m_things[i];
			if (thing.IsVisible(!gameUIVisible)) {
				thing.UpdateProportions();
				thing.InternalRender(visState);
			}
		}

	}


	void renderCircles() {
		for (int i = 0; i < visState_length; i++) {
			vec2 centerPos = Camera::ToScreenSpace(VehicleState::GetAllVis(GetApp().GameScene)[i].AsyncState.Position);
			bool hovering = ((centerPos - UI::GetMousePos()).LengthSquared() < circle_radius ** 2);
			if (hovering) {
				nvg::BeginPath();
				nvg::Circle(centerPos, circle_radius);
				nvg::FillColor(vec4(.3, .3, 1, 1));
				nvg::Fill();
				nvg::ClosePath();
			} else {
				if (show_circles || i == active_visState) {
					nvg::BeginPath();
					nvg::Circle(centerPos, circle_radius);
					nvg::FillColor(vec4(1, 1, 1, 1));
					nvg::Fill();
					nvg::ClosePath();
				}
			}
		}
	}

	void handleCarClick(int pos) {
		if (show_circles) {
			active_visState = pos;
			show_circles = false;
			alt_car_selection = true;
		} else {
			show_circles = true;
		}
	}

	void OnMouseButton(bool down, int button, int x, int y) {
		if (down) {
			for (int i = 0; i < visState_length; i++) {
				auto currentState = VehicleState::GetAllVis(GetApp().GameScene)[i];
				vec2 centerPos = Camera::ToScreenSpace(currentState.AsyncState.Position);
				if ((centerPos - UI::GetMousePos()).LengthSquared() < circle_radius ** 2) {
					handleCarClick(i);
				}
			}
		}

	}
}

