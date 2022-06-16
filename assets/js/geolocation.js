let Hook = {
    mounted() {
        const view = this;
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(getLocation, errorHandler, {maximumAge: 60000, timeout: 60000, enableHighAccuracy: false});
        } else {
            alert("Geolocation not available in this browser");
        }

        function getLocation(position) {
            view.pushEvent("update-geolocation", [position.coords.latitude, position.coords.longitude]);
        }

        function errorHandler(err) {
            alert("there was an error with geolocation");
        }
    }
};

export default Hook;
