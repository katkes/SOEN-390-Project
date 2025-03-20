import {
  getMapData,
  show3dMap,
} from "https://cdn.jsdelivr.net/npm/@mappedin/mappedin-js@beta/lib/esm/index.js";

const options = {
  key: "MAPPEDIN_API_KEY",
  secret: "MAPPEDIN_API_SECRET",
  mapId: "MAPPEDIN_API_MAP_ID",
};

// Initialize Map
const mapData = await getMapData(options);
const mapView = await show3dMap(
  document.getElementById("mappedin-map"),
  mapData
);

mapView.Labels.all();
mapView.enableDebug();

window.setCameraTo = function setCameraTo(spaceId) {
  const space = mapData.getByType("space").find(s => s.id === spaceId);
  if (space && mapView) {
    mapView.Camera.animateTo({
      center: space.geometry.center,
      zoomLevel: 20,
      pitch: 45,
      bearing: 0,
    });
  }
};

window.setFloor = function setFloor(floorName) {
  try {
    const floors = mapData.getByType("floor");
    const targetFloor = floors.find(floor => floor.name === floorName);

    if (!targetFloor) {
      throw new Error(`Floor "${floorName}" not found`);
    }

    if (!mapView) {
      throw new Error("mapView is not initialized");
    }

    mapView.setFloor(targetFloor.id);

    const message = JSON.stringify({
      type: "success",
      payload: { status: "success", floorName: floorName, floorId: floor.id }
    });

    Floors.postMessage(message);

  } catch (error) {
    const message = JSON.stringify({
      type: "error",
      payload: { message: error.message }
    });
    Floors.postMessage(message);
  }
};


window.getDirections = async function getDirections(startName, destinationName) {
  try {
    const spaces = mapData.getByType("space");
    const startSpace = spaces.find(s => s.name === startName);
    const destinationSpace = spaces.find(s => s.name === destinationName);

    if (!startSpace || !destinationSpace) {
      throw new Error("Invalid start or destination");
    }

    const directions = await mapData.getDirections(startSpace, destinationSpace);
    if (!directions || !directions.path) {
      throw new Error("Directions not found");
    }

    mapView.Navigation.clear();
    mapView.Navigation.draw(directions);

    const successMessage = {
      type: "success",
      payload: {
        distance: directions.distance,
        directions: directions.instructions,
      }
    };
    DirectionsChannel.postMessage(JSON.stringify(successMessage));
    return JSON.stringify(successMessage);
  } catch (err) {
    const errorMessage = {
      type: "error",
      payload: { message: err.message }
    };
    DirectionsChannel.postMessage(JSON.stringify(errorMessage));
    return JSON.stringify(errorMessage);
  }
};

// Populate Floor Selector
const floorSelect = document.getElementById("floor-select");
const floors = mapData.getByType("floor");

floors.sort((a, b) => a.elevation - b.elevation);
floors.forEach((floor) => {
  const option = document.createElement("option");
  option.value = floor.id;
  option.textContent = floor.name;
  floorSelect.appendChild(option);
});

// Handle Floor Selection
floorSelect.addEventListener("change", () => {
  const selectedFloorId = floorSelect.value;
  if (selectedFloorId) {
    mapView.setFloor(selectedFloorId);
  }
});
