//
//  ContentView.swift
//  MultipleImagePickerSwiftUI
//
//  Created by JeongminKim on 2022/02/01.
//

import SwiftUI
import Photos

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @State var selected: [UIImage] = []
    @State var data: [Images] = []
    @State var show: Bool = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.07).edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    self.selected.removeAll()
                    self.show.toggle()
                }, label: {
                    Text("Image Picker")
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(width: UIScreen.main.bounds.width / 2)
                })
                .background(Color.red)
                .clipShape(Capsule())
            }
            
            if self.show {
                CustomPicker(selected: self.$selected, data: self.$data, show: self.$show)
            }
        }
    }
}

struct CustomPicker: View {
    @Binding var selected: [UIImage]
    @Binding var data: [Images]
    @State var grid: [Int] = []
    @Binding var show: Bool
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack {
                        if !self.grid.isEmpty {
                            HStack {
                                Text("Pick a Image")
                                    .fontWeight(.bold)
                                
                                Spacer()
                            }
                            .padding(.leading)
                            .padding(.top)
                            
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(spacing: 20) {
                                    ForEach(self.grid, id: \.self) { i in
                                        HStack(spacing: 8) {
                                            ForEach(i..<i+3, id: \.self) { j in
                                                HStack {
                                                    if j < self.data.count {
                                                        Card(data: self.data[j])
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            Indicator()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height / 1.5)
                    .background(Color.white)
                    .cornerRadius(12)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
        .onTapGesture {
            self.show.toggle()
        }
        .onAppear {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.getAllImages()
                } else {
                    print("Not authorized")
                }
            }
        }
    }
    
    func getAllImages() {
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        
        DispatchQueue.global(qos: .background).async {
            req.enumerateObjects { phAsset, int, objcBool in
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                PHCachingImageManager.default().requestImage(for: phAsset, targetSize: .init(), contentMode: .default, options: options) { image, dictionary in
                    print("CustomPicker - getAllImages() - \(image?.pngData())")
                    let data1 = Images(image: image!, selected: false)
                    self.data.append(data1)
                }
            }
            
            if req.count == self.data.count {
                self.getGrid()
            }
        }
    }
    
    func getGrid() {
        for i in stride(from: 0, to: self.data.count, by: 3) {
            self.grid.append(i)
        }
    }
}

struct Images {
    var image: UIImage
    var selected: Bool
}

struct Card: View {
    var data: Images
    
    var body: some View {
        Image(uiImage: self.data.image)
            .resizable()
            .frame(width: (UIScreen.main.bounds.width - 80) / 3, height: 90)
    }
}

struct Indicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}
