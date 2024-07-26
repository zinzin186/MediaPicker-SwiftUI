//
//  File.swift
//  
//
//  Created by Alisa Mylnikova on 04.09.2023.
//

import SwiftUI
import AVFoundation

public struct PlayerView: UIViewRepresentable {

    public var player: AVPlayer
    public var bgColor: Color
    public var useFill: Bool
    
    public init(player: AVPlayer, bgColor: Color, useFill: Bool) {
        self.player = player
        self.bgColor = bgColor
        self.useFill = useFill
    }

    public func makeUIView(context: Context) -> PlayerUIView {
        PlayerUIView(player: player, bgColor: bgColor, useFill: useFill)
    }

    public func updateUIView(_ uiView: PlayerUIView, context: UIViewRepresentableContext<PlayerView>) {
        uiView.playerLayer.player = player
        uiView.playerLayer.videoGravity = useFill ? .resizeAspectFill : .resizeAspect
    }
}

public class PlayerUIView: UIView {

    // MARK: Class Property

    let playerLayer = AVPlayerLayer()

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(player: AVPlayer, bgColor: Color, useFill: Bool) {
        super.init(frame: .zero)
        self.playerSetup(player: player, bgColor: bgColor, useFill: useFill)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Life-Cycle

    override public func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    // MARK: Class Methods

    private func playerSetup(player: AVPlayer, bgColor: Color, useFill: Bool) {
        playerLayer.player = player
        playerLayer.videoGravity = useFill ? .resizeAspectFill : .resizeAspect
        player.actionAtItemEnd = .none
        layer.addSublayer(playerLayer)
        playerLayer.backgroundColor = bgColor.cgColor
    }
}
