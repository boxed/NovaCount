//
//  ContentView.swift
//  NovaCount
//
//  Created by Anders Hovmöller on 2020-07-05.
//  Copyright © 2020 Anders Hovmöller. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var numbers = -100...100
    
    var body: some View {
        VStack(alignment: .center) {
            Text("⭐️⭐️").font(.system(size: 20))
            Text("3 + 4").foregroundColor(Color.white).font(.system(size: 60))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(self.numbers, id: \.self) { number in
                        Text("\(number)")
                            .foregroundColor(Color.white)
                            .frame(width: 60, height: 70)
                            .background(
                          RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.purple)
                        )
                    }
                }
            }
            .padding(.horizontal)
            Button(action: {}) {
                Text("Svara").foregroundColor(Color.white).padding()
            }
            .background(RoundedRectangle(cornerRadius: 4.0).stroke(Color.purple))
        }
        .background(Rectangle().fill(Color.black))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
       

    }
}
