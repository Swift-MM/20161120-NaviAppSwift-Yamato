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
    
    
    
    
    
    
    
    
    
    
    
}

