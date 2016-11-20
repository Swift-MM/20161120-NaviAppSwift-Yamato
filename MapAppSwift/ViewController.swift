//
//  ViewController.swift
//  MapAppSwift
//
//  Created by Matt Deuschle on 1/8/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var segmentControl: UISegmentedControl!
    
    var mangaer = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // 長押しのUIGestureRecognizerを生成.
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(ViewController.recognizeLongPress(sender:)))
        
        
        // MapViewにUIGestureRecognizerを追加.
        mapView.addGestureRecognizer(myLongPress)
        
        // 出発点の緯度、経度を設定.
        let myLatitude: CLLocationDegrees = 37.331741
        let myLongitude: CLLocationDegrees = -122.030333
        
        // 目的地の緯度、経度を設定.
        let requestLatitude: CLLocationDegrees = 37.427474
        let requestLongitude: CLLocationDegrees = -122.169719
        
        // 目的地の座標を指定.
        let requestCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(requestLatitude, requestLongitude)
        let fromCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(myLatitude, myLongitude)
        
        //地図の中心を出発点と目的地の中間に設定する.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake((myLatitude + requestLatitude)/2, (myLongitude + requestLongitude)/2)
        
        // mapViewに中心をセットする.
        mapView.setCenter(center, animated: true)
        
        // 縮尺を指定.
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        // regionをmapViewにセット.
        mapView.region = myRegion
        
        //        // viewにmapViewを追加.
        //        self.view.addSubview(mapView)
        
        // ピンを生成.
        let fromPin: MKPointAnnotation = MKPointAnnotation()
        let toPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標をセット.
        fromPin.coordinate = fromCoordinate
        toPin.coordinate = requestCoordinate
        
        // titleをセット.
        fromPin.title = "出発地点"
        toPin.title = "目的地"
        
        // mapViewに追加.
        mapView.addAnnotation(fromPin)
        mapView.addAnnotation(toPin)
        
        
        // PlaceMarkを生成して出発点、目的地の座標をセット.
        let fromPlace: MKPlacemark = MKPlacemark(coordinate: fromCoordinate, addressDictionary: nil)
        let toPlace: MKPlacemark = MKPlacemark(coordinate: requestCoordinate, addressDictionary: nil)
        
        
        // Itemを生成してPlaceMarkをセット.
        let fromItem: MKMapItem = MKMapItem(placemark: fromPlace)
        let toItem: MKMapItem = MKMapItem(placemark: toPlace)
        
        // MKDirectionsRequestを生成.
        let myRequest: MKDirectionsRequest = MKDirectionsRequest()
        
        // 出発地のItemをセット.
        myRequest.source = fromItem
        
        // 目的地のItemをセット.
        myRequest.destination = toItem
        
        // 複数経路の検索を有効.
        myRequest.requestsAlternateRoutes = true
        
        // 移動手段を車に設定.
        myRequest.transportType = MKDirectionsTransportType.automobile
        
        // MKDirectionsを生成してRequestをセット.
        let myDirections: MKDirections = MKDirections(request: myRequest)
        
        // 経路探索.
        myDirections.calculate { (response, error) in
            
            // NSErrorを受け取ったか、ルートがない場合.
            if error != nil || response!.routes.isEmpty {
                return
            }
            
            let route: MKRoute = response!.routes[0] as MKRoute
            print("目的地まで \(route.distance)km")
            print("所要時間 \(Int(route.expectedTravelTime/60))分")
            
            // mapViewにルートを描画.
            self.mapView.add(route.polyline)
            
            
        }
        
    }
    
    
    
    /*
     長押しを感知した際に呼ばれるメソッド.
     */
    func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        
        // 長押しした地点の座標を取得.
        let location = sender.location(in: mapView)
        
        // locationをCLLocationCoordinate2Dに変換.
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        
        // ピンを生成.
        let myPin: MKPointAnnotation = MKPointAnnotation()
        
        // 座標を設定.
        myPin.coordinate = myCoordinate
        
        // タイトルを設定.
        myPin.title = "目的地"
        
        
        // MapViewにピンを追加.
        mapView.addAnnotation(myPin)
    }
    
    /*
     addAnnotationした際に呼ばれるデリゲートメソッド.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let myPinIdentifier = "PinAnnotationIdentifier"
        
        // ピンを生成.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        
        // アニメーションをつける.
        myPinView.animatesDrop = true
        
        // コールアウトを表示する.
        myPinView.canShowCallout = true
        
        // annotationを設定.
        myPinView.annotation = annotation
        
        return myPinView
    }
    
    
    @IBAction func directions(_ sender: AnyObject) {
        
        // set up URL link for directions
        UIApplication.shared.openURL(URL(string: "http://maps.apple.com/maps?daddr=37.3092293,-122.1136845")!)
        
    }
    
    
    @IBAction func mapType(_ sender: AnyObject) {
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            mapView.mapType = MKMapType.standard
        }
        if (segmentControl.selectedSegmentIndex == 1)
        {
            mapView.mapType = MKMapType.satellite
        }
        if (segmentControl.selectedSegmentIndex == 2)
        {
            mapView.mapType = MKMapType.hybrid
        }
        
    }
    
    @IBAction func locateMe(_ sender: AnyObject) {
        
        // trigger the locate me button
        mangaer.delegate = self
        mangaer.desiredAccuracy = kCLLocationAccuracyBest
        mangaer.requestWhenInUseAuthorization()
        mangaer.startUpdatingLocation()
        mapView.showsUserLocation = true
        
    }
    
    //once we get user location, set up zoom effect
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // once we get location, stop updating so it will display
        manager.stopUpdatingLocation()
        
        // get long and lat of th "userLocation"
        let location = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        // how far to zoom in
        let span = MKCoordinateSpanMake(0.5, 0.5)
        
        // set up region of zoom
        let region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
    }
    
    // ルートの表示設定.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
        
        // ルートの線の太さ.
        routeRenderer.lineWidth = 3.0
        
        // ルートの線の色.
        routeRenderer.strokeColor = UIColor.red
        return routeRenderer
    }
    
    
}

