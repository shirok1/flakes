{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "xiaomi_weather";
  version = "0.1.0-unstable";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-xiaomi-weather";
    rev = "75f7664bc0669557cba9d4dac3eb2db2804864c8";
    hash = "sha256-0oiPlyPfvBZy1h8zOrpzBZzFTgixpGNPpjEKb16Aksw=";
  };

  meta = {
    description = "Xiaomi Weather integration for Home Assistant: current conditions, daily/hourly forecasts and China AQI/PM2.5/PM10 sensors via the Xiaomi weather cloud API, configurable through the UI";
    homepage = "https://github.com/shirok1/hass-xiaomi-weather";
    license = lib.licenses.mit;
  };
}
