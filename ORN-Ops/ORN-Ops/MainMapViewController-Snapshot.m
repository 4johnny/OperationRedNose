#ifdef IGNORE


- (void)mapView:(MKMapView*)mapView didSelectRidePointAnnotationWithRide:(Ride*)ride {
	
	
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse* response, NSError* error) {
		
...
		// Add polyline from team assigned location to actual route start, if possible
		if (ride.teamAssigned && ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude) {
			
			CLLocationCoordinate2D startCoordinate = MKCoordinateForMapPoint(route.polyline.points[0]);
			
			RideTeamAssignedPolyline* rideTeamAssignedPolylineToRouteStart = [RideTeamAssignedPolyline rideTeamAssignedPolylineWithRide:ride andStartCoordinate:&startCoordinate];
			
			[self.mainMapView addOverlay:rideTeamAssignedPolylineToRouteStart level:MKOverlayLevelAboveLabels];
		}
		
		// Add route polyline from ride start to end
		RideStartEndPolyline* rideStartEndPolyline = [RideStartEndPolyline rideStartEndPolylineWithRide:ride andPolyline:route.polyline];
		[self.mainMapView addOverlay:rideStartEndPolyline level:MKOverlayLevelAboveRoads];
	}];
}


@end


#endif