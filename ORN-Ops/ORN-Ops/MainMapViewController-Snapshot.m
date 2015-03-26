#ifdef IGNORE


@implementation MainMapViewController-SNAPSHOT


#
# pragma mark <MKMapViewDelegate> Helpers
#


- (void)mapView:(MKMapView*)mapView didSelectRidePointAnnotationWithRide:(Ride*)ride {
	
	// If cannot get directions request, we are done with this ride
	MKDirectionsRequest* directionsRequest = ride.getDirectionsRequest;
	if (!directionsRequest) return;
	
	// Determine route for ride, and add overlay to map asynchronously
	MKDirections* directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse* response, NSError* error) {
		
		// NOTES: Completion block executes on main thread. Do not run more than one directions calculation simultaneously on this object.
		if (error) {
			NSLog(@"ETA Error: %@ %@", error.localizedDescription, error.userInfo);
			return;
		}
		
		// Route directions calculated successfully, so grab first one
		// NOTE: Should be exactly 1, since we did not request alternate routes
		MKRoute* route = response.routes.firstObject;
		
		// Update expected travel time for ride, since may have changed
		ride.duration = [NSNumber numberWithDouble:route.expectedTravelTime]; // seconds
		NSLog(@"ETA: %.0f sec -> %.2f min", route.expectedTravelTime, route.expectedTravelTime / (double)SECONDS_PER_MINUTE);
		
		// Determine end time by adding ETA seconds to start time
		ride.dateTimeEnd = [NSDate dateWithTimeInterval:route.expectedTravelTime sinceDate:ride.dateTimeStart];
		
		// Store distance in ride
		ride.distance = [NSNumber numberWithDouble:route.distance]; // meters
		
		// Notify that ride and assigned team have updated
		[[NSNotificationCenter defaultCenter] postNotificationName:RIDE_UPDATED_NOTIFICATION_NAME object:self userInfo:@{RIDE_ENTITY_NAME:ride}];
		if (ride.teamAssigned) {
			[[NSNotificationCenter defaultCenter] postNotificationName:TEAM_UPDATED_NOTIFICATION_NAME object:self userInfo:@{TEAM_ENTITY_NAME:ride.teamAssigned}];
		}
		
		// If neither ride nor team assigned is selected, we are done
		if (![self isSelectedAnnotationForRide:ride] && ![self isSelectedAnnotationForTeam:ride.teamAssigned]) return;
		
		// Remove existing ride-team assigned polyline, if present
		if (rideTeamAssignedPolylineToRideStart) {
			[self.mainMapView removeOverlay:rideTeamAssignedPolylineToRideStart];
		}
		
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


#
# pragma mark Notification Handlers
#


- (void)updateRideStartEndOverlaysWithNotification:(NSNotification*)notification {
	
//	// Find map overlays for given ride start-end route
//	// NOTE: Should be max 1
//	Ride* ride = notification.userInfo[RIDE_ENTITY_NAME];
//	NSArray* overlaysAffected = [self.mainMapView.overlays filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
//		
//		return [evaluatedObject isKindOfClass:[RideStartEndPolyline class]] && ((RideStartEndPolyline*)evaluatedObject).ride == ride;
//	}]];
}


- (void)updateRideTeamAssignedOverlaysWithNotification:(NSNotification*)notification {
	
	// If team assigned has not been updated, we are done.
	// NOTE: Good enough for now.  Later, start and end locations might also be changing
	BOOL updatedTeamAssigned = (notification.userInfo[RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY] && ((NSNumber*)notification.userInfo[RIDE_UPDATED_TEAM_ASSIGNED_NOTIFICATION_KEY]).boolValue);
	if (!updatedTeamAssigned) return;
	
	// Find map overlays for given ride-team assigned
	// NOTE: Should be max 1
	Ride* ride = notification.userInfo[RIDE_ENTITY_NAME];
	NSArray* overlaysAffected = [self.mainMapView.overlays filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary* bindings) {
		
		return [evaluatedObject isKindOfClass:[RideTeamAssignedPolyline class]] && ((RideTeamAssignedPolyline*)evaluatedObject).ride == ride;
	}]];
	
	// Remove ride-team assigned overlay, if present
	RideTeamAssignedPolyline* rideTeamAssignedPolyline = nil;
	if (overlaysAffected.count > 0) {
		
		rideTeamAssignedPolyline = overlaysAffected.firstObject;
		[self.mainMapView removeOverlay:rideTeamAssignedPolyline];
	}
	
	// If neither ride nor team assigned is selected, we are done
	if (![self isSelectedAnnotationForRide:ride] && ![self isSelectedAnnotationForTeam:ride.teamAssigned]) return;
	
	// Add overlay for ride-team, if assigned and possible
	if (ride.teamAssigned && ride.teamAssigned.locationCurrentLatitude && ride.teamAssigned.locationCurrentLongitude && ride.locationStartLatitude && ride.locationStartLongitude) {
		
		// Get coordinate of route start, if possible; o/w ride start
		CLLocationCoordinate2D startCoordinate = rideTeamAssignedPolyline ? MKCoordinateForMapPoint(rideTeamAssignedPolyline.points[rideTeamAssignedPolyline.pointCount - 1]) : CLLocationCoordinate2DMake(ride.locationStartLatitude.doubleValue, ride.locationStartLongitude.doubleValue);
		
		// Populate polyline - reuse existing object if present
		if (rideTeamAssignedPolyline) {
			
			rideTeamAssignedPolyline = [rideTeamAssignedPolyline initWithRide:ride andStartCoordinate:&startCoordinate];
			
		} else {
			
			rideTeamAssignedPolyline = [RideTeamAssignedPolyline rideTeamAssignedPolylineWithRide:ride andStartCoordinate:&startCoordinate];
		}
		
		// Add polyline to overlays
		[self.mainMapView addOverlay:rideTeamAssignedPolyline level:MKOverlayLevelAboveLabels];
	}
}


@end


#endif