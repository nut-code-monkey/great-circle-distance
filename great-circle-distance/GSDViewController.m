//
//  GSDViewController.m
//  great-circle-distance
//
//  Created by Max on 14.06.14.
//  Copyright (c) 2014 Max Lunin. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "GSDViewController.h"

@interface GSDViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define SIGN(number) ( (number) > 0. ? 1. : -1. )

BOOL shouldExit(CGFloat lon, CGFloat maxLon, CGFloat step)
{
    if (step > 0) {
        return lon < maxLon;
    }
    else{
        return lon > maxLon;
    }
}

@implementation GSDViewController

-(NSArray*)pathBetween:( CLLocationCoordinate2D )first
           secondPoint:( CLLocationCoordinate2D )second
                  step:( CGFloat )stepDegrees
{
    CGFloat stepRadians = DEGREES_TO_RADIANS(stepDegrees) * SIGN(second.longitude - first.longitude);
    
    CGFloat fromLatitude = DEGREES_TO_RADIANS(first.latitude);
    CGFloat toLatitude = DEGREES_TO_RADIANS(second.latitude);

    CGFloat fromLongitude = DEGREES_TO_RADIANS(first.longitude);
    CGFloat toLongitude = DEGREES_TO_RADIANS(second.longitude);
    
    NSMutableArray* points = [@[[[CLLocation alloc] initWithLatitude:first.latitude longitude:first.longitude]] mutableCopy];
    
    for (CGFloat longitude = fromLongitude; shouldExit(longitude, toLongitude, stepRadians) ; longitude += stepRadians)
    {
        CGFloat latitude = atan(  (tan(fromLatitude)*sin(toLongitude-longitude)) / sin(toLongitude-fromLongitude)
                                + (tan(toLatitude)*sin(longitude-fromLongitude)) / sin(toLongitude-fromLongitude) );
        
        [points addObject:[[CLLocation alloc] initWithLatitude:RADIANS_TO_DEGREES(latitude)
                                                     longitude:RADIANS_TO_DEGREES(longitude)]];
    }
    
    [points addObject:[[CLLocation alloc] initWithLatitude:second.latitude longitude:second.longitude]];
    
    return points;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSArray* path = [self pathBetween:CLLocationCoordinate2DMake(29.979514, 31.134169)
                          secondPoint:CLLocationCoordinate2DMake(40.719163, -74.005469)
                                 step:0.1];
    
    CLLocationCoordinate2D points[path.count];
    
    for (NSUInteger i= 0; i < path.count; ++i)
        points[i] = [path[i] coordinate];
    
    [self.mapView addOverlay:[MKPolygon polygonWithCoordinates:points count:path.count]];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:( MKPolyline* )overlay
{
    MKOverlayPathView* overlayPathView = [[MKPolylineView alloc] initWithPolyline:overlay];
    overlayPathView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
    overlayPathView.lineWidth = 3;
    return overlayPathView;
}

@end
