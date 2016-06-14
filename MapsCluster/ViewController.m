//
//  ViewController.m
//  BlueAirMapCluster
//
//  Created by Adam Barta on 10/28/15.
//  Copyright © 2015 flatcircle. All rights reserved.
//

#define ENABLE_CLUSTER

//#define ENABLE_CLUSER1

#import "ViewController.h"
#import "ClusterAnnotationView.h"
#import <MapKit/MapKit.h>

#ifdef ENABLE_CLUSTER
#import "CCHMapClusterController.h"
#import "CCHCenterOfMassMapClusterer.h"
#import "CCHNearCenterMapClusterer.h"
#import "CCHMapClusterAnnotation.h"
#import "CCHMapClusterControllerDelegate.h"
#endif

#ifdef ENABLE_CLUSER1
#import "OCMapView.h"
#endif


@import AddressBookUI;

@interface ViewController () <MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource
#ifdef ENABLE_CLUSTER
,CCHMapClusterControllerDelegate>
#else
>
#endif

#ifdef ENABLE_CLUSTER
@property (strong, nonatomic) CCHMapClusterController *mapClusterController;
@property (strong, nonatomic) CCHMapClusterController *mapClusterController2;
@property (nonatomic) id<CCHMapClusterer> mapClusterer;
#endif

@property (weak, nonatomic) IBOutlet UIButton *stop_btn;
#ifdef ENABLE_CLUSER1
@property (strong, nonatomic) IBOutlet OCMapView *map_view;
#else
@property (weak, nonatomic) IBOutlet MKMapView *map_view;
#endif

@property (nonatomic,strong) NSMutableArray<MKAnnotationView *> *map_annotation_views;

@property (nonatomic, assign) BOOL map_loaded;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) CLGeocoder *geoco;

@property (nonatomic, strong) NSArray<CLPlacemark *> * last_geocode;

@property (weak, nonatomic) IBOutlet UITableView *auto_complete_table_view;


@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.map_view setDelegate:self];
    
    self.timer = nil;
    
    self.geoco = [[CLGeocoder alloc] init];
    
    [self.auto_complete_table_view setDelegate:self];
    [self.auto_complete_table_view setDataSource:self];
    
#ifdef ENABLE_CLUSTER
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.map_view];
    self.mapClusterController2 = [[CCHMapClusterController alloc] initWithMapView:self.map_view];
    self.mapClusterer = //[[CCHCenterOfMassMapClusterer alloc] init];
                        [[CCHNearCenterMapClusterer alloc] init];
    self.mapClusterController.clusterer = self.mapClusterer;
    self.mapClusterController2.clusterer = self.mapClusterer;
    [self.mapClusterController setDelegate:self];
    [self.mapClusterController2 setDelegate:self];
#endif
    
#ifdef ENABLE_CLUSTER1
     self.map_view.clusterSize = 0.2f;
#endif
    
    //self.mapClusterController.debuggingEnabled  = YES;
    
#if 0
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-33.925219,.longitude=18.424076}]]; //ct
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-33.926825,.longitude=18.861330}]]; //stellies
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-33.965062,.longitude=18.475562}]]; //rondebosch
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-34.047762,.longitude=18.375501}]]; //houtbay
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-34.182415,.longitude=18.424228}]]; //simonstown
    [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=-33.952041,.longitude=18.382410}]]; //campsbay
#else
    NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"locs" ofType:@"txt"] encoding:NSASCIIStringEncoding error:nil];
    NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
    int i=0;
    for (NSString* line in lines) {
        if (line.length) {
            
            NSArray *gps = [line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" \t"]];

            if (gps.count == 2)
                [self process_annotation:[self create_point_annotation:(CLLocationCoordinate2D){.latitude=[gps[0] doubleValue],.longitude=[gps[1] doubleValue]}] withId:i++];
            
        }
    }
#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (MKPointAnnotation *) create_point_annotation:(CLLocationCoordinate2D) coord
{
    MKPointAnnotation * pt = [[MKPointAnnotation alloc] init];
    [pt setCoordinate:coord];
    return pt;
}

- (void) process_annotation:(MKPointAnnotation *) anno
                     withId:(int) i
{
#ifdef ENABLE_CLUSTER
    if (i < 500){
        //anno.q
        [self.mapClusterController addAnnotations:[NSArray arrayWithObject:anno] withCompletionHandler:^{}];
    }
    else {
        
        [self.mapClusterController2 addAnnotations:[NSArray arrayWithObject:anno] withCompletionHandler:^{}];
    }
#else
    [self.map_view addAnnotation:anno];
#endif
}



- (IBAction)text_box_editing:(id)sender
{
    UITextField *tf = sender;
    
    if ([self.geoco isGeocoding])
        [self.geoco cancelGeocode];
    
    [self.geoco geocodeAddressString:tf.text completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        self.last_geocode = placemarks;
        [self.auto_complete_table_view reloadData];
    }];
    
}




- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.last_geocode.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *cid = @"tablecellx";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tablecellx"];
    }
    
    CLPlacemark *place = self.last_geocode[indexPath.row];
    
    [cell.textLabel setText:[NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(place.addressDictionary, YES)]];
     
    return cell;
}

- (void)tableView:(UITableView *)tableView
didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
    CLPlacemark *place = self.last_geocode[indexPath.row];
    
    [pt setCoordinate:place.location.coordinate];

    [self process_annotation:pt withId:0];
    [self.map_view setCenterCoordinate:pt.coordinate animated:YES];
}







- (IBAction)stop_btn_touch:(id)sender
{
    [self.timer invalidate];
    self.timer = nil;
}

- (IBAction)start_btn_touch:(id)sender
{
    if (!self.timer)
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(gen_point:) userInfo:nil repeats:YES];
}



-(void) gen_point: (NSTimer *) timer
{
    
    MKPointAnnotation *pt = [[MKPointAnnotation alloc] init];
    
    [pt setCoordinate:[self generateRandomCoord]];
    
    [self process_annotation:pt withId:0];
    [self.map_view setCenterCoordinate:pt.coordinate animated:YES];
}

- (float) randomFloatWithMin:(float) Min
                     withMax:(float) Max
{
    return ((arc4random()%RAND_MAX)/(RAND_MAX*1.0))*(Max-Min)+Min;
}


- (CLLocationCoordinate2D) generateRandomCoord
{
    CLLocationCoordinate2D c;
    
    c.latitude = [self randomFloatWithMin:-89.f withMax:89.f];
    c.longitude = [self randomFloatWithMin:-179.f withMax:179.f];
    
    NSLog(@"gem %@", [NSString stringWithFormat:@"%f %f", c.latitude, c.longitude]);

    return c;
}







#pragma mark - MKMapViewDelegate methods


- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
#ifdef ENABLE_CLUSTER
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"clusterAnnotation";
        
        ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.map_view dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (clusterAnnotationView) {
            clusterAnnotationView.annotation = annotation;
        } else {
            clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            clusterAnnotationView.canShowCallout = YES;
        }
        
        CCHMapClusterAnnotation *clusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        clusterAnnotationView.count = clusterAnnotation.annotations.count;
        clusterAnnotationView.uniqueLocation = clusterAnnotation.isUniqueLocation;
        
        if (clusterAnnotation.mapClusterController == self.mapClusterController){
            clusterAnnotationView.clusterbkg = [UIColor colorWithRed:0.00 green:0.51 blue:0.76 alpha:1.0];
        } else if (clusterAnnotation.mapClusterController == self.mapClusterController2){
            clusterAnnotationView.clusterbkg = [UIColor colorWithRed:0.51 green:0.76 blue:0.0 alpha:1.0];
        }
        
        [annotationView setCanShowCallout:YES];
        
        annotationView = clusterAnnotationView;
    }
    return annotationView;
#elif ENABLE_CLUSTER1
    MKAnnotationView *annotationView;
    
    static NSString *identifier = @"clusterAnnotation";
    
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.map_view dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (clusterAnnotationView) {
        clusterAnnotationView.annotation = annotation;
    } else {
        clusterAnnotationView = [[ClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        clusterAnnotationView.canShowCallout = YES;
    }
    
    // if it's a cluster
    if ([annotation isKindOfClass:[OCAnnotation class]]) {
        // create your custom cluster annotationView here!
        NSLog(@"%s: is cluster", __func__);
    }
    // If it's a single annotation
    else if([annotation isKindOfClass:[MKPointAnnotation class]]){
        // create your custom annotationView  as regular here!
        NSLog(@"%s: is point", __func__);
    }
    
    clusterAnnotationView.count = clusterAnnotation.annotations.count;
    clusterAnnotationView.uniqueLocation = clusterAnnotation.isUniqueLocation;
    
    [annotationView setCanShowCallout:YES];
    
    annotationView = clusterAnnotationView;
    
    return annotationView;
#else
    MKPointAnnotation *pt = annotation;
    
    NSString *ptstr = [NSString stringWithFormat:@"%f %f",pt.coordinate.latitude, pt.coordinate.longitude];
    
    [pt setTitle:ptstr];
    
    static NSString* ruid = @"arndpoint";
    
    MKPinAnnotationView *piw = (MKPinAnnotationView *)[self.map_view dequeueReusableAnnotationViewWithIdentifier:ruid];
    if (!piw)
        piw = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ruid];
    
    [piw setCanShowCallout:YES];
    
    return piw;
#endif
}

- (void)mapView:(MKMapView *)mapView
didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *pt = view.annotation;

    NSLog(@"%s %@", __func__, [NSString stringWithFormat:@"%f %f", pt.coordinate.latitude, pt.coordinate.longitude]);
        
    [self.geoco reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:pt.coordinate.latitude longitude:pt.coordinate.longitude] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        for (CLPlacemark *place in placemarks){
            NSLog(@"%s: place %@ %@", __func__, pt.title, place.addressDictionary);
        }
        
    }];
}


- (void)mapView:(MKMapView *)mapView
didDeselectAnnotationView:(MKAnnotationView *)view
{
    NSLog(@"%s", __func__);
}

#ifdef ENABLE_CLUSTER
- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    ClusterAnnotationView *clusterAnnotationView = (ClusterAnnotationView *)[self.map_view viewForAnnotation:mapClusterAnnotation];
    clusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    clusterAnnotationView.uniqueLocation = mapClusterAnnotation.isUniqueLocation;
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    NSUInteger numAnnotations = mapClusterAnnotation.annotations.count;

    return [NSString stringWithFormat:@"%@",(mapClusterAnnotation.isUniqueLocation?[NSString stringWithFormat:@"%f %f",mapClusterAnnotation.coordinate.latitude,mapClusterAnnotation.coordinate.longitude]:[NSString stringWithFormat:@"%tu annotations",numAnnotations])];
}
#endif


@end
