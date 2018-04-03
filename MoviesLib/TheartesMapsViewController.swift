//
//  TheartesMapsViewController.swift
//  MoviesLib
//
//  Created by Usuário Convidado on 02/04/18.
//  Copyright © 2018 EricBrito. All rights reserved.
//

import UIKit
import MapKit

class TheartesMapsViewController: UIViewController {
    
    
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: - Properties
    var currentElement: String!
    var theater: Theater!
    var theaters: [Theater] = []
    lazy var locationManager = CLLocationManager()
    
    
    
    
    //MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
   
        loadXML()
        mapView.delegate = self
        requestUserLocationAuthorization()
    }

    
    //MARK: - Methods
    func loadXML(){
        guard   let xml = Bundle.main.url(forResource: "theaters", withExtension: "xml"), let xmlParser = XMLParser(contentsOf: xml) else {return}
        
        xmlParser.delegate = self
        xmlParser.parse()
        
        
    }
    
    func addTheaters(){
        
        for theater in theaters {
            let coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            
            let annotation = TheaterAnnotation(coordinate: coordinate, title: theater.name, subtitle: theater.address )
            
            mapView.addAnnotation(annotation)
            
            
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            //locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = true
            
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print ("acesso ja concedido")
                
                case .denied:
                    print ("usuario negou")
                
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                
                case .restricted:
                    print("nao rolou acesso")
            }
        }
    }

}

//implementando o delegate do xmlparser
//MARK: - XMLParserDelegate
extension TheartesMapsViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentElement = elementName
        
        if elementName == "Theater" {
            theater = Theater()
            
        }
        
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let content = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !content.isEmpty {
            switch currentElement {
            case "name":
                theater.name = content
            case "address":
                theater.address = content
            case "latitude":
                theater.latitude = Double(content)!
            case "longitude":
                theater.longitude = Double(content)!
            case "url":
                theater.url = content
            default:
                break;
                
            }
        }
        print (string)
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Theater" {
            
            theaters.append(theater)
        }
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        addTheaters()
    }
    
}

//MARK: - MKMapViewDelegate
extension TheartesMapsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView: MKAnnotationView!
        
        if annotation is TheaterAnnotation {
            
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Theater")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Theater")
                annotationView.image = UIImage(named: "theaterIcon")
                annotationView.canShowCallout = true
                
            } else{
                annotationView.annotation = annotation
            }
        }
        
        
        return annotationView
    }
    
}

//MARK: - CLLocationManagerDelegate

extension TheartesMapsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            mapView.showsUserLocation = true
        default:
            break
        }
        
        
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        print("velocidade do usuario: \(userLocation.location?.speed ?? 0)")
        
        let regiao = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 500, 500)
        
        
        mapView.setRegion(regiao, animated: true)
        
    }
    
}

