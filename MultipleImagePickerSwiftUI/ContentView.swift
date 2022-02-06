//
//  ContentView.swift
//  MultipleImagePickerSwiftUI
//
//  Created by JeongminKim on 2022/02/01.
//

import SwiftUI
import Photos // MARK: Do not forget to import Photos!

struct ContentView: View {
    var body: some View {
        Home()
    }
}

// MARK: 'Home' shows main contents
struct Home: View {
    
    @State var selected: [UIImage] = []
    @State var show: Bool = false
    var body: some View {
        ZStack {
            Color.black.opacity(0.07).edgesIgnoringSafeArea(.all)
            
            VStack {
                if !self.selected.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(self.selected, id: \.self) { i in
                                Image(uiImage: i)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 40, height: 250)
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }

                
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
                .padding(.top, 25)
            }
            
            if self.show {
                CustomPicker(selected: self.$selected, show: self.$show)
            }
        }
    }
}

// MARK: Show image list
struct CustomPicker: View {
    @Binding var selected: [UIImage]
    @State var data: [Images] = []
    @State var grid: [Int] = []
    @Binding var show: Bool
    @State var disabled = false
    
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
                                                        Card(data: self.data[j], selected: self.$selected)
                                                    }
                                                }
                                            }
                                            
                                            if self.data.count % 3 != 0 && i == self.grid.last! {

                                                Spacer()
                                            }

                                        }
                                        .padding(.leading, (self.data.count % 3 != 0 && i == self.grid.last!) ? 15 : 0)
                                    }
                                }
                            }
                            
                            Button(action: {
                                self.show.toggle()
                            }, label: {
                                Text("Select")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width / 2)
                            })
                            .background(Color.red.opacity((self.selected.count != 0) ? 1 : 0.5))
                            .clipShape(Capsule())
                            .padding(.bottom, 25)
                            .disabled((self.selected.count != 0) ? false : true)
                            
                        } else {
                            if self.disabled {
                                Text("Enable Storage Access In Settings!!!")
                            } else {
                                Indicator()
                            }
                            
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
            // MARK: Request authorization(You need to add 'Privacy - Photo Library Usage Description' into your info.plist)
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.getAllImages()
                    self.disabled = false
                } else {
                    print("Not authorized")
                    self.disabled = true
                }
            }
        }
    }
    
    // MARK: Get all images from your photo app
    func getAllImages() {
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        
        DispatchQueue.global(qos: .background).async {
            req.enumerateObjects { phAsset, int, objcBool in
                
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                PHCachingImageManager.default().requestImage(for: phAsset, targetSize: .init(), contentMode: .default, options: options) { image, dictionary in
                    print("CustomPicker - getAllImages() - \(image?.pngData())")
                    let imageData = Images(image: image!, selected: false)
                    self.data.append(imageData)
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

// MARK: Defines image model type
struct Images {
    var image: UIImage
    var selected: Bool
}

// MARK: Shows each image status(selected or not)
struct Card: View {
    @State var data: Images
    @Binding var selected: [UIImage]
    
    var body: some View {
        ZStack {
            Image(uiImage: self.data.image)
                .resizable()
            
            if self.data.selected {
                ZStack {
                    Color.black.opacity(0.5)
                    
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
        }
        .frame(width: (UIScreen.main.bounds.width - 80) / 3, height: 90)
        .onTapGesture {
            if !self.data.selected {
                self.data.selected = true
                self.selected.append(self.data.image)
            } else {
                for i in 0..<self.selected.count {
                    if self.selected[i] == self.data.image {
                        self.selected.remove(at: i)
                        self.data.selected = false
                        return
                    }
                }
            }
        }
    }
}

// MARK: Show indicator until loading is complete
struct Indicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}
