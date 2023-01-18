//
//  ViewController.swift
//  Project16
//
//  Created by Phillip Reynolds on 1/17/23.
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics")
        
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a 1000 years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington, D.C", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Map Type", style: .plain, target: self, action: #selector(chooseMapType))
    }
    
    @objc func chooseMapType() {
        let ac = UIAlertController(title: "Map Type", message: "Which map type would you like to use.", preferredStyle: .actionSheet)
        
        let satelliteChoice = UIAlertAction(title: "Satellite", style: .default, handler: changeMapType)
        let standardChoice = UIAlertAction(title: "Standard", style: .default, handler: changeMapType)
        let hybridChoice = UIAlertAction(title: "Hybrid", style: .default, handler: changeMapType)
        
        ac.addAction(satelliteChoice)
        ac.addAction(standardChoice)
        ac.addAction(hybridChoice)
        
        present(ac, animated: true)
    }
    
    func changeMapType(_ action: UIAlertAction) {
        switch action.title {
        case "Satellite":
            mapView.mapType = .satellite
        case "Standard":
            mapView.mapType = .standard
        case "Hybrid":
            mapView.mapType = .hybrid
        default:
            mapView.mapType = .standard
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        guard annotation is Capital else { return nil }

        // 2
        let identifier = "Capital"

        // 3
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            //4
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true

            // 5
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            // 6
            annotationView?.annotation = annotation
        }
        
        annotationView?.pinTintColor = UIColor.green

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title

        let vc = DetailViewController()
        vc.capital = placeName
        navigationController?.pushViewController(vc, animated: true)
    }
}

