import FSCalendar

class A4xHomeCalendarCell : FSCalendarCell {
    
    override func layoutSubviews() {
        self.subtitleLabel.isHidden = true
        let titleMaxHeight : CGFloat = 25
        
        self.titleLabel.frame = CGRect(x: 0, y: 1, width: self.contentView.width, height: titleMaxHeight)


        let diameter = min(titleMaxHeight, self.contentView.width)
        
        self.shapeLayer.frame = CGRect(x: (self.contentView.width - diameter)/2.0, y: 1, width: diameter, height: diameter)
        
        let path : CGPath = UIBezierPath(roundedRect: self.shapeLayer.bounds, cornerRadius: diameter * 0.5).cgPath
        
        if path != self.shapeLayer.path {
            self.shapeLayer.path = path
        }
        
        self.eventIndicator.frame = CGRect(x: 0, y: self.titleLabel.fs_bottom + 4  , width: self.contentView.width, height: 4)
    }
}
