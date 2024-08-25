//
//  Created by Alex.M on 06.06.2022.
//

import SwiftUI

struct LiveCameraCell: View {

    let action: () -> Void
    
    @StateObject private var liveCameraViewModel = LiveCameraViewModel()
    @State private var orientation = UIDevice.current.orientation
    
    var body: some View {
        Button {
            action()
        } label: {
            LiveCameraView(
                session: liveCameraViewModel.captureSession,
                videoGravity: .resizeAspectFill,
                orientation: orientation
            )
            .overlay(
                Image("ic_camera", bundle: .current)
                    .foregroundColor(.white)
            )
        }
        .onEnteredBackground(perform: liveCameraViewModel.stopSession)
        .onEnteredForeground(perform: liveCameraViewModel.startSession)
        .onRotate { orientation = $0 }
    }
}
