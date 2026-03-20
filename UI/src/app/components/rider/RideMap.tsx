import { useEffect, useRef } from 'react';
import L from 'leaflet';
import { Navigation, ZoomIn, ZoomOut, Maximize2 } from 'lucide-react';

interface RideMapProps {
  pickupLocation: string;
  dropoffLocation: string;
  estimatedTime?: string;
}

// Function to geocode location names to coordinates (mock for demo)
const getCoordinatesForLocation = (location: string): [number, number] => {
  // Mock coordinates for demo - Real coordinates around San Francisco area
  const locationMap: Record<string, [number, number]> = {
    'Current Location': [37.7749, -122.4194], // San Francisco
    '123 Main St, Downtown': [37.7849, -122.4094],
    '456 Business Ave, Corporate Center': [37.7649, -122.4294],
    'International Airport Terminal 1': [37.6213, -122.3790],
    'Central Plaza Mall, 5th Avenue': [37.7849, -122.4094],
    'General Hospital, Medical District': [37.7749, -122.4394],
    'Central Station, Railway St': [37.7949, -122.3994],
    'Downtown Business District': [37.7849, -122.4094],
    'Sunset Beach, Coastal Road': [37.7749, -122.5094],
    'Food Street, Culinary Quarter': [37.7649, -122.4194],
    'State University Campus': [37.8749, -122.2594],
    'City Sports Stadium': [37.7549, -122.3894],
  };
  
  return locationMap[location] || [37.7749, -122.4194];
};

export function RideMap({ pickupLocation, dropoffLocation, estimatedTime }: RideMapProps) {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<L.Map | null>(null);

  useEffect(() => {
    if (!mapRef.current || mapInstanceRef.current) return;

    const pickupCoords = getCoordinatesForLocation(pickupLocation);
    const dropoffCoords = getCoordinatesForLocation(dropoffLocation);

    // Calculate center point
    const center: [number, number] = [
      (pickupCoords[0] + dropoffCoords[0]) / 2,
      (pickupCoords[1] + dropoffCoords[1]) / 2
    ];

    // Initialize the map with better settings
    const map = L.map(mapRef.current, {
      center: center,
      zoom: 13,
      zoomControl: false, // We'll add custom controls
      scrollWheelZoom: true,
      dragging: true,
      touchZoom: true,
      doubleClickZoom: true,
      boxZoom: true,
      keyboard: true,
      tap: true,
    });

    mapInstanceRef.current = map;

    // Add multiple tile layer options for better reliability
    // Using OpenStreetMap's standard tiles (most reliable free option)
    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      maxZoom: 19,
      minZoom: 3,
      crossOrigin: true,
    }).addTo(map);

    // Alternative: You can also use CartoDB for a cleaner look
    // L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
    //   attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
    //   maxZoom: 20,
    // }).addTo(map);

    // Create custom pickup icon (blue circle)
    const pickupIcon = L.divIcon({
      html: `<div style="width: 32px; height: 32px; background: #2563eb; border-radius: 50%; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 12px rgba(0,0,0,0.3); border: 3px solid white;">
               <div style="width: 10px; height: 10px; background: white; border-radius: 50%;"></div>
             </div>`,
      className: 'custom-marker-pickup',
      iconSize: [32, 32],
      iconAnchor: [16, 16],
      popupAnchor: [0, -16],
    });

    // Create custom dropoff icon (red pin)
    const dropoffIcon = L.divIcon({
      html: `<svg width="32" height="42" viewBox="0 0 32 42" fill="none" xmlns="http://www.w3.org/2000/svg">
               <path d="M16 0C7.163 0 0 7.163 0 16c0 13.5 16 26 16 26s16-12.5 16-26c0-8.837-7.163-16-16-16z" fill="#dc2626"/>
               <circle cx="16" cy="16" r="8" fill="white"/>
             </svg>`,
      className: 'custom-marker-dropoff',
      iconSize: [32, 42],
      iconAnchor: [16, 42],
      popupAnchor: [0, -42],
    });

    // Add pickup marker
    const pickupMarker = L.marker(pickupCoords, { icon: pickupIcon }).addTo(map);
    pickupMarker.bindPopup(`
      <div style="text-align: center;">
        <div style="font-weight: 600; color: #2563eb; font-size: 14px; margin-bottom: 4px;">Pickup</div>
        <div style="font-size: 12px; color: #374151;">${pickupLocation}</div>
      </div>
    `);

    // Add dropoff marker
    const dropoffMarker = L.marker(dropoffCoords, { icon: dropoffIcon }).addTo(map);
    dropoffMarker.bindPopup(`
      <div style="text-align: center;">
        <div style="font-weight: 600; color: #dc2626; font-size: 14px; margin-bottom: 4px;">Destination</div>
        <div style="font-size: 12px; color: #374151;">${dropoffLocation}</div>
      </div>
    `);

    // Add route line
    const routeLine = L.polyline([pickupCoords, dropoffCoords], {
      color: '#3B82F6',
      weight: 4,
      opacity: 0.8,
      dashArray: '10, 10',
    }).addTo(map);

    // Fit bounds to show both markers
    const bounds = L.latLngBounds([pickupCoords, dropoffCoords]);
    map.fitBounds(bounds, { padding: [50, 50], maxZoom: 14 });

    // Cleanup on unmount
    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, [pickupLocation, dropoffLocation]);

  return (
    <div className="relative w-full h-full bg-gray-200">
      <div ref={mapRef} className="w-full h-full z-0" style={{ minHeight: '300px' }} />
      
      {/* Custom Zoom Controls */}
      <div className="absolute right-4 top-1/2 -translate-y-1/2 z-[1000] flex flex-col gap-2">
        <button
          onClick={() => mapInstanceRef.current?.zoomIn()}
          className="w-10 h-10 bg-white rounded-lg shadow-lg flex items-center justify-center hover:bg-gray-50 active:bg-gray-100 transition-colors border border-gray-200"
          aria-label="Zoom in"
        >
          <ZoomIn className="w-5 h-5 text-gray-700" />
        </button>
        <button
          onClick={() => mapInstanceRef.current?.zoomOut()}
          className="w-10 h-10 bg-white rounded-lg shadow-lg flex items-center justify-center hover:bg-gray-50 active:bg-gray-100 transition-colors border border-gray-200"
          aria-label="Zoom out"
        >
          <ZoomOut className="w-5 h-5 text-gray-700" />
        </button>
        <button
          onClick={() => {
            const pickupCoords = getCoordinatesForLocation(pickupLocation);
            const dropoffCoords = getCoordinatesForLocation(dropoffLocation);
            const bounds = L.latLngBounds([pickupCoords, dropoffCoords]);
            mapInstanceRef.current?.fitBounds(bounds, { padding: [50, 50], maxZoom: 14 });
          }}
          className="w-10 h-10 bg-white rounded-lg shadow-lg flex items-center justify-center hover:bg-gray-50 active:bg-gray-100 transition-colors border border-gray-200"
          aria-label="Fit to route"
        >
          <Maximize2 className="w-5 h-5 text-gray-700" />
        </button>
      </div>
      
      {/* Distance Badge */}
      {estimatedTime && (
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-white/95 backdrop-blur-sm px-4 py-2 rounded-full shadow-lg border border-gray-200 z-[1000] pointer-events-none">
          <div className="flex items-center gap-2 text-sm">
            <Navigation className="w-4 h-4 text-blue-600" />
            <span className="font-semibold text-gray-900">{estimatedTime}</span>
          </div>
        </div>
      )}
    </div>
  );
}