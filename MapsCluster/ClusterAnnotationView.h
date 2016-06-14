//
//  ClusterAnnotationView.h
//  BlueAirMapCluster
//
//  Created by Adam Barta on 10/29/15.
//  Copyright © 2015 flatcircle. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface ClusterAnnotationView : MKAnnotationView

@property (nonatomic) NSUInteger count;
@property (nonatomic, getter = isUniqueLocation) BOOL uniqueLocation;

@property (nonatomic, assign) UIColor *clusterbkg;

@end
