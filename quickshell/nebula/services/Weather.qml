pragma Singleton

import QtQuick
import Quickshell
import M3Shapes

Singleton {
    id: root

    readonly property string city: Settings.weather.city.trim()
    readonly property bool enabled: city !== ""

    property string place: ""
    property real latitude: NaN
    property real longitude: NaN
    property bool loading: false
    property string error: ""
    property real updated: 0

    property var current: null
    property var days: []

    readonly property var today: days[0] ?? null

    function describe(code, day = true) {
        if (code === 0) return { text: "Clear", icon: day ? "sunny" : "clear_night", shape: day ? MaterialShape.Sunny : MaterialShape.Circle };
        if (code <= 2) return { text: "Partly cloudy", icon: day ? "partly_cloudy_day" : "partly_cloudy_night", shape: MaterialShape.Cookie9Sided };
        if (code === 3) return { text: "Cloudy", icon: "cloud", shape: MaterialShape.Puffy };
        if (code <= 48) return { text: "Fog", icon: "foggy", shape: MaterialShape.Ghostish };
        if (code <= 57) return { text: "Drizzle", icon: "rainy_light", shape: MaterialShape.Pill };
        if (code <= 67) return { text: "Rain", icon: "rainy", shape: MaterialShape.Slanted };
        if (code <= 77) return { text: "Snow", icon: "weather_snowy", shape: MaterialShape.Flower };
        if (code <= 82) return { text: "Showers", icon: "rainy", shape: MaterialShape.Slanted };
        if (code <= 86) return { text: "Snow showers", icon: "weather_snowy", shape: MaterialShape.Flower };
        return { text: "Thunderstorm", icon: "thunderstorm", shape: MaterialShape.SoftBoom };
    }

    function time(iso) {
        return iso ? iso.split("T")[1] ?? "" : "";
    }

    function get(url, done) {
        const request = new XMLHttpRequest();
        request.onreadystatechange = () => {
            if (request.readyState !== XMLHttpRequest.DONE) return;
            if (request.status !== 200) {
                root.loading = false;
                root.error = "Couldn't reach the weather service";
                return;
            }
            try {
                done(JSON.parse(request.responseText));
            } catch (e) {
                root.loading = false;
                root.error = "Weird answer from the weather service";
            }
        };
        request.open("GET", url);
        request.send();
    }

    function locate() {
        if (!enabled) {
            place = "";
            latitude = NaN;
            longitude = NaN;
            current = null;
            days = [];
            return;
        }
        loading = true;
        error = "";
        get(`https://geocoding-api.open-meteo.com/v1/search?count=1&language=en&name=${encodeURIComponent(city)}`, data => {
            const hit = data.results?.[0];
            if (!hit) {
                loading = false;
                error = `Couldn't find "${city}"`;
                current = null;
                days = [];
                return;
            }
            place = hit.name;
            latitude = hit.latitude;
            longitude = hit.longitude;
            refresh();
        });
    }

    function refresh() {
        if (isNaN(latitude)) {
            locate();
            return;
        }
        loading = true;
        get(`https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}`
            + "&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m,is_day"
            + "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset"
            + "&timezone=auto&forecast_days=5", data => {
            const c = data.current;
            current = {
                temp: Math.round(c.temperature_2m),
                feels: Math.round(c.apparent_temperature),
                humidity: c.relative_humidity_2m,
                wind: Math.round(c.wind_speed_10m),
                code: c.weather_code,
                day: c.is_day === 1
            };
            const d = data.daily;
            days = d.time.map((date, i) => ({
                date: new Date(date + "T12:00"),
                code: d.weather_code[i],
                max: Math.round(d.temperature_2m_max[i]),
                min: Math.round(d.temperature_2m_min[i]),
                rain: d.precipitation_probability_max[i] ?? 0,
                sunrise: time(d.sunrise[i]),
                sunset: time(d.sunset[i])
            }));
            updated = Date.now();
            loading = false;
            error = "";
        });
    }

    function refreshIfOld() {
        if (enabled && !loading && Date.now() - updated > 10 * 60 * 1000) refresh();
    }

    onCityChanged: locateTimer.restart()

    Timer {
        id: locateTimer
        interval: 800
        onTriggered: root.locate()
    }

    Timer {
        running: root.enabled
        repeat: true
        interval: 30 * 60 * 1000
        onTriggered: root.refresh()
    }

    Component.onCompleted: locate()
}
