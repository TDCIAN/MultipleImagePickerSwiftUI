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
    var body: some View {
        ZStack {
            Color.black.opacity(0.07).edgesIgnoringSafeArea(.all)
            
            VStack {
                Button(action: {
                    
                }, label: {
                    Text("Image Picker")
                        .foregroundColor(.white)
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width / 2)
                })
                .background(Color.red)
                .clipShape(Capsule())
            }
            
            CustomPicker(selected: self.$selected, data: self.$data)
        }
    }
}

struct CustomPicker: View {
    @Binding var selected: [UIImage]
    @Binding var data: [Images]
    
    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
            }
        }
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
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
        }
    }
}

struct Images {
    var image: UIImage
    var selected: Bool
}
