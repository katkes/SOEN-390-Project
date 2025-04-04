    /**
     * Initializes and renders a 3D indoor map using Mappedin JS SDK.
     *
     * Dynamically injects credentials via placeholders for secure loading in WebView.
     * Exposes global JS functions for Flutter-to-JS communication:
     * - window.getDirections(start, destination): Draws path on map.
     * - window.setFloor(floorName): Changes visible floor.
     * - window.setCameraTo(spaceName): Animates camera to a named space.
     *
     * Also sets up a dropdown selector for manual floor switching.
     */

    import {
          getMapData,
          show3dMap,
    } from "https://cdn.jsdelivr.net/npm/@mappedin/mappedin-js@beta/lib/esm/index.js";

    // Placeholder API credentials to be replaced at runtime
    const options = {
        key: "MAPPEDIN_API_KEY",
        secret: "MAPPEDIN_API_SECRET",
        mapId: "MAPPEDIN_API_MAP_ID",
    };

    // Load map data and render 3D view
    const mapData = await getMapData(options);
    const mapView = await show3dMap(
        document.getElementById("mappedin-map"),
        mapData
    );

    mapView.Labels.all();

    //This is the functionality which adds the "black box" at the top and allows us to access
    //a lot of the mappedIN SDK functionality for quick debugging and testing.
    //mapView.enableDebug();



    /**
     * Moves camera to the center of a named space.
     *
     * - [spaceName]: Name of the space to focus on.
     */
    window.setCameraTo = function setCameraTo(spaceName) {
        const space = mapData.getByType("space").find(s => s.name === spaceName);
        if (space && mapView) {
            mapView.Camera.animateTo({
                center: space.geometry.center,
                zoomLevel: 20,
                pitch: 45,
                bearing: 0,
            });
        }
    };

    /**
     * Changes the visible floor on the map and notifies Flutter.
     *
     * - [floorName]: Name of the target floor.
     *
     * Sends success or error message via `FloorsChannel.postMessage()`.
     */
    window.setFloor = function setFloor(floorName) {
        try {
            const floors = mapData.getByType("floor");
            const targetFloor = floors.find(floor => floor.name === floorName);

            if (!targetFloor) throw new Error(`Floor "${floorName}" not found`);
            if (!mapView) throw new Error("mapView is not initialized");

            mapView.setFloor(targetFloor.id);

            FloorsChannel.postMessage(JSON.stringify({
                type: "success",
                payload: { status: "success", floorName, floorId: targetFloor.id }
            }));
        } catch (error) {
            FloorsChannel.postMessage(JSON.stringify({
                type: "error",
                payload: { message: error.message }
            }));
        }
    };

    /**
     * Draws directions between two named spaces and notifies Flutter.
     *
     * - [startName]: Name of starting space.
     * - [destinationName]: Name of destination space.
     *
     * Sends directions or error via `DirectionsChannel.postMessage()`.
     */
    window.getDirections = async function getDirections(startName, destinationName, accessible) {
        try {
            const spaces = mapData.getByType("space");
            const start = spaces.find(s => s.name === startName);
            const destination = spaces.find(s => s.name === destinationName);

            if (!start || !destination) throw new Error("Invalid start or destination");


            const directions = await mapData.getDirections(start, destination, { accessible: accessible });
            if (!directions?.path) throw new Error("Directions not found");

            mapView.Navigation.clear();
            mapView.Navigation.draw(directions);

            const msg = {
                type: "success",
                payload: {
                    distance: directions.distance,
                    directions: directions.instructions,
                }
            };
            DirectionsChannel.postMessage(JSON.stringify(msg));
        } catch (err) {
            const msg = {
                type: "error",
                payload: { message: err.message }
            };
            DirectionsChannel.postMessage(JSON.stringify(msg));
        }
    };

    window.search = function search(identifier) {
        console.log("Working search called with identifier:", identifier);

        // Try to find the space by roomName
        let space = mapData.getByType("space").find(s => s.name === identifier);
        if (space) {
            console.log("Room found by name:", space);
        } else {
            console.log("Room not found by name, trying by number...");
            space = mapData.getByType("space").find(s => s.number === identifier);
            if (space) {
                console.log("Room found by number:", space);
            }
        }

        if (space) {
            // Log the entire space object as JSON for better inspection
            console.log("Space object details:", JSON.stringify(space, null, 2)); // Pretty-print the object

            if (mapView) {
                console.log("Highlighting room:", space);

                // Highlight the selected room by changing its state
                mapView.updateState(space, {
                    interactive: true,
                    hoverColor: "#f26336", // Changing the hover color
                    opacity: 1.0,          // Full opacity for visibility
                    border: "5px solid #FF4500", // Adding a red border for visibility
                    boxShadow: "0 0 15px rgba(255, 99, 71, 0.8)", // Adding a glowing effect
                });

                const spaceElement = document.getElementById(space.id);
                if (spaceElement) {
                    console.log("Space element found:", spaceElement);
                    spaceElement.style.backgroundColor = "#f26336"; // Example color
                    spaceElement.style.border = "3px solid #FF4500";
                    spaceElement.style.boxShadow = "0 0 10px rgba(255, 99, 71, 0.8)";
                    spaceElement.style.animation = "pulseEffect 1s infinite";
                } else {
                    console.error("Space element not found for ID:", space.id);
                }
            }
        } else {
            console.error("Room not found:", identifier);
        }
    };





    // Populate floor dropdown UI
    const floorSelect = document.getElementById("floor-select");
    const floors = mapData.getByType("floor");

    floors.sort((a, b) => a.elevation - b.elevation);
    floors.forEach((floor) => {
        const option = document.createElement("option");
        option.value = floor.id;
        option.textContent = floor.name;
        floorSelect.appendChild(option);
    });

    // Handle dropdown floor selection
    floorSelect.addEventListener("change", () => {
        const selectedFloorId = floorSelect.value;
        if (selectedFloorId) {
            mapView.setFloor(selectedFloorId);
        }
    });





    const spaces = mapData.getByType("space");


    // Tap-to-select behavior
    function setSpacesInteractive(interactive) {
        spaces.forEach((space) => {
            mapView.updateState(space, {
                interactive: interactive,
                hoverColor: interactive ? "#f26336" : null,
            });
        });
    }

    setSpacesInteractive(true);

    let clickedStart = null;
    let path = null;

    mapView.on("click", async (event) => {
        if (!event?.spaces?.length) return;
        console.log('Map clicked');

        const clickedSpace = event.spaces[0];

        if (!clickedStart) {
            clickedStart = clickedSpace;
            console.log(`Start room: ${clickedStart.name}`);
        } else if (!path) {
            const directions = await mapData.getDirections(
                clickedStart,
                clickedSpace
            );

            if (!directions?.coordinates?.length) {
                console.log("No valid path found.");
                return;
            }

            // Clear Navigation (in case dropdown was used before)
            mapView.Navigation.clear();

            path = mapView.Paths.add(directions.coordinates, {
                nearRadius: 0.5,
                farRadius: 0.5,
                color: "#912338",
            });

            updateDirectionsPanel(directions);
            setSpacesInteractive(false);
        } else {
            mapView.Paths.removeAll();
            clickedStart = null;
            path = null;
            setSpacesInteractive(true);
            console.log("Path cleared. Tap to start again.");
        }
    });


