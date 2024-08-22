//
//  Created by Alex.M on 27.05.2022.
//

import SwiftUI

struct AlbumView: View {

    @EnvironmentObject private var selectionService: SelectionService
    @EnvironmentObject private var permissionsService: PermissionsService
    @Environment(\.mediaPickerTheme) private var theme

    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper.shared

    @StateObject var viewModel: AlbumViewModel
    @Binding var showingCamera: Bool
    @Binding var disableScroll: Bool
    @Binding var currentFullscreenMedia: Media?

    var shouldShowCamera: Bool
    var shouldShowLoadingCell: Bool
    var selectionParamsHolder: SelectionParamsHolder
    var shouldDismiss: ()->()
    var onTapItem: (Media)->()

    @State private var fullscreenItem: AssetMediaModel?

    var body: some View {
        if let title = viewModel.title {
            content.navigationTitle(title)
        } else {
            content
        }
    }
}

private extension AlbumView {

    @ViewBuilder
    var content: some View {
        ScrollingModifier(disabled: $disableScroll) {
            VStack {
                if let action = permissionsService.photoLibraryAction {
                    PermissionsActionView(action: .library(action))
                }
                if shouldShowCamera, let action = permissionsService.cameraAction {
                    PermissionsActionView(action: .camera(action))
                }
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if viewModel.assetMediaModels.isEmpty, !shouldShowLoadingCell {
                    Text("Empty data")
                        .font(.title3)
                        .foregroundColor(theme.main.text)
                } else {
                    MediasGrid(viewModel.assetMediaModels) {
#if !targetEnvironment(simulator)
                        if shouldShowCamera && permissionsService.cameraAction == nil {
                            LiveCameraCell {
                                showingCamera = true
                            }
                        }
#endif
                    } content: { assetMediaModel in
                        cellView(assetMediaModel)
                    } loadingCell: {
                        if shouldShowLoadingCell {
                            ZStack {
                                Color.white.opacity(0.5)
                                ProgressView()
                            }
                            .aspectRatio(1, contentMode: .fit)
                        }
                    }
                    .onChange(of: viewModel.assetMediaModels) { newValue in 
                        selectionService.updateSelection(with: newValue)
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .background(theme.main.albumSelectionBackground)
        .onTapGesture {
            if keyboardHeightHelper.keyboardDisplayed {
                dismissKeyboard()
            }
        }
//        .overlay(
//            FullscreenContainer(
//                isPresented: fullscreenPresentedBinding(),
//                currentFullscreenMedia: $currentFullscreenMedia,
//                assetMediaModels: viewModel.assetMediaModels,
//                selection: fullscreenItem?.id ?? "",
//                selectionParamsHolder: selectionParamsHolder,
//                shouldDismiss: shouldDismiss
//            )
//        )
    }

    func fullscreenPresentedBinding() -> Binding<Bool> {
        Binding(
            get: { fullscreenItem != nil },
            set: { value in
                if value == false {
                    fullscreenItem = nil
                }
            }
        )
    }

    @ViewBuilder
    func cellView(_ assetMediaModel: AssetMediaModel) -> some View {
        let imageButton = Button {
            if keyboardHeightHelper.keyboardDisplayed {
                dismissKeyboard()
            }
            if !selectionParamsHolder.showFullscreenPreview { // select immediately
                selectionService.onSelect(assetMediaModel: assetMediaModel)
                if selectionService.mediaSelectionLimit == 1 {
                    shouldDismiss()
                }
            }
            else {
                onTapItem(Media(source: assetMediaModel))
                if selectionService.selected.first(where: {$0.id == assetMediaModel.id}) == nil {
                    selectionService.onSelect(assetMediaModel: assetMediaModel)
                }
            }
//            if fullscreenItem == nil {
//                fullscreenItem = assetMediaModel
//            } 
        } label: {
            MediaCell(viewModel: MediaViewModel(assetMediaModel: assetMediaModel))
        }
        .buttonStyle(MediaButtonStyle())
        .contentShape(Rectangle())

        if selectionService.mediaSelectionLimit == 1 {
            imageButton
        } else {
            SelectableView(selected: selectionService.index(of: assetMediaModel), isFullscreen: false, canSelect: selectionService.canSelect(assetMediaModel: assetMediaModel), selectionParamsHolder: selectionParamsHolder) {
                selectionService.onSelect(assetMediaModel: assetMediaModel)
            } content: {
                imageButton
            }
        }
    }

}

struct ScrollingModifier<Content> : View where Content : View {

    @Binding var disabled: Bool
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ScrollView{
                content()
            }.scrollDisabled(disabled)
        } else {
            if disabled {
                content()
            } else {
                ScrollView {
                    content()
                }
            }
        }
    }
    
}
