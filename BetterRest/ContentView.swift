//
//  ContentView.swift
//  BetterRest
//
//  Created by Samuel Hernandez Vicera on 3/5/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var showingAlert = false
    
    var recommendedSleepTime: String {
        return calculateBedtime()
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form {
                
                Section("When do you want to wake up?"){
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep"){
             
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section("Daily coffee intake"){
                    Picker("Coffee Amount", selection: $coffeeAmount){
                        ForEach(0..<20){
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
                Section("Recommended Sleep Time"){
                    Text(String(recommendedSleepTime))
                }
            }
            .navigationTitle("BetterRest")
            
        }
    }
    
    func calculateBedtime() -> String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let calculatedSleepTime = sleepTime.formatted(date: .omitted, time: .shortened)
            
           
            
//            alertTitle = "Your ideal bedtime is..."
//            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            return calculatedSleepTime
            
        } catch {
//            alertTitle = "Error"
//            alertMessage = "Sorry there was a problem calculating your bedtime"
        }
//        showingAlert = true
        return "Error calculating recommended sleep time"
    }
}

#Preview {
    ContentView()
}
