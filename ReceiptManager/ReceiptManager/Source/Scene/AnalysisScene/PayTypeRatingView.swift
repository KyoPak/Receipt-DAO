//
//  PayTypeRatingView.swift
//  ReceiptManager
//
//  Created by parkhyo on 12/10/23.
//

import UIKit

final class PayTypeRatingView: UIView {
    
    // UI Properties
    
    private let cashLabel = UILabel(text: ConstantText.cash.localize(), font: .systemFont(ofSize: 13))
    private let cardLabel = UILabel(text: ConstantText.card.localize(), font: .systemFont(ofSize: 13))
    
    private let cashImage: UIImageView = {
        let imageView = UIImageView(image: ConstantColor.mainColor.image())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let cardImage: UIImageView = {
        let imageView = UIImageView(image: ConstantColor.subColor.image())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Properties
    
    private var percentValues: [CGFloat] = []
    var caseValues: [Int] = []
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        calculateRating(caseCount: caseValues)
        
        let total = percentValues.reduce(0, +)
        var startAngle: CGFloat = (-(.pi) / 2)
        var endAngle: CGFloat = 0.0
        
        for index in 0..<percentValues.count {
            endAngle = (percentValues[index] / total) * (.pi * 2)
            
            let path = UIBezierPath()
            path.move(to: center)
            path.addArc(
                withCenter: center,
                radius: 60,
                startAngle: startAngle,
                endAngle: startAngle + endAngle,
                clockwise: true
            )
            
            drawTextIfNeeded(at: center, startAngle: startAngle, endAngle: endAngle, index: index)
            drawSlice(path, index: index)
            
            startAngle += endAngle
            path.close()
        }
        
        drawInnerCircle(center)
    }
    
    // Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Calculate
extension PayTypeRatingView {
    private func calculateRating(caseCount: [Int]) {
        let total = caseCount.reduce(0, +)
        percentValues.removeAll()
        
        for count in caseCount {
            let rating = CGFloat((Double(count) / Double(total)) * 100)
            percentValues.append(rating)
        }
    }
}

// MARK: - Draw Chart
extension PayTypeRatingView {
    private func drawSlice(_ path: UIBezierPath, index: Int) {
        if index == 0 {
            ConstantColor.mainColor.set()
        } else {
            ConstantColor.subColor.set()
        }
        
        path.fill()
        drawSliceSpace(path)
    }
    
    private func drawSliceSpace(_ path: UIBezierPath) {
        ConstantColor.cellColor.set()
        path.lineWidth = 3
        path.stroke()
    }
    
    private func drawInnerCircle(_ center: CGPoint) {
        let semiCircle = UIBezierPath(
            arcCenter: center,
            radius: 40,
            startAngle: 0,
            endAngle: (360 * .pi) / 180,
            clockwise: true
        )
        
        ConstantColor.cellColor.set()
        semiCircle.fill()
    }
    
    private func drawTextIfNeeded(at center: CGPoint, startAngle: CGFloat, endAngle: CGFloat, index: Int) {
        guard percentValues[index] != .zero else { return }
        
        let midAngle = startAngle + (endAngle / 2)
        let textPosition = CGPoint(x: center.x + 85 * cos(midAngle), y: center.y + 80 * sin(midAngle))
        
        let percentText = String(format: "%.1f%%", percentValues[index])
        let caseText = "\(caseValues[index])" + ConstantText.caseText.localize()
        let combinedText = percentText + "\n" + caseText
        drawText(combinedText, at: textPosition)
    }
    
    private func drawText(_ text: String, at position: CGPoint) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.label
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: position.x - textSize.width / 2,
            y: position.y - textSize.height / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
    }
}

// MARK: - UI Constraints
extension PayTypeRatingView {
    private func setupHierarchy() {
        [cashLabel, cashImage, cardLabel, cardImage].forEach(addSubview(_:))
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cashLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            cashLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 10),

            cashImage.topAnchor.constraint(equalTo: cashLabel.topAnchor),
            cashImage.leadingAnchor.constraint(equalTo: cashLabel.trailingAnchor, constant: 10),
            cashImage.heightAnchor.constraint(equalTo: cashLabel.heightAnchor),
            cashImage.widthAnchor.constraint(equalTo: cashLabel.widthAnchor),

            cardLabel.topAnchor.constraint(equalTo: cashLabel.bottomAnchor, constant: 8),
            cardLabel.leadingAnchor.constraint(equalTo: cashLabel.leadingAnchor),

            cardImage.topAnchor.constraint(equalTo: cardLabel.topAnchor),
            cardImage.leadingAnchor.constraint(equalTo: cardLabel.trailingAnchor, constant: 10),
            cardImage.heightAnchor.constraint(equalTo: cardLabel.heightAnchor),
            cardImage.widthAnchor.constraint(equalTo: cashLabel.widthAnchor)
        ])
    }
}
