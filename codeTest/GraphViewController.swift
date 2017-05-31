//
//  GameViewController.swift
//  codeTest
//
//  Created by Yogesh Sharma on 25/05/17.
//  Copyright © 2017 Yogesh Sharma. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, CPTScatterPlotDataSource ,CPTPlotSpaceDelegate, CPTScatterPlotDelegate, CPTPlotAreaDelegate, CPTAxisDelegate, CALayerDelegate {
    
    private var chartXData: [String]!
    private var chartYData: [String]!
    private let minXRange: Int! = 0
    private var maxXRange: Int!
    private var minYRange: Double!
    private var maxYRange: Double!
    private var xLength: Int!
    private var yLength: Int!
    
    private var Graph = CPTXYGraph(frame: CGRect.zero)
    
    fileprivate var point1: [NSNumber]?


    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var tooltip: UILabel!
    @IBOutlet weak var returns: UILabel!
    @IBOutlet weak var percentage: UILabel!
    @IBOutlet weak var graph: CPTGraphHostingView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartXData = ["Dec", "Jan", "Feb", "Mar", "Apr"]
        chartYData = ["11.00","19.20","17.20","22.80","20.95"]
        minYRange = 5
        maxYRange = 30
        maxXRange = chartXData.count - 1
        xLength = Int(maxXRange - minXRange)
        yLength = Int(maxYRange - minYRange)
        
        //Create graph object
        let newGraph = CPTXYGraph(frame: CGRect.zero)
        
        //Create hosting view
        graph.hostedGraph = newGraph
        
        //padding
        newGraph.paddingLeft   = 0.0
        newGraph.paddingBottom = 0.0
        newGraph.paddingRight  = 0.0
        newGraph.paddingTop    = 80.0
        
        newGraph.plotAreaFrame?.paddingLeft   = 10.0
        newGraph.plotAreaFrame?.paddingBottom = 30.0
        newGraph.plotAreaFrame?.paddingRight  = 5.0
        newGraph.plotAreaFrame?.paddingTop    = 0.0
        newGraph.plotAreaFrame?.masksToBorder = false;
        newGraph.plotAreaFrame?.masksToBounds = false;
        
        
        //MARK: PLOT SPACE
        let plotSpace                   = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.delegate              = self
        plotSpace.allowsUserInteraction = false
        
        let xRange = CPTPlotRange(location: minXRange! as NSNumber, length: NSNumber(value: xLength!))
        let yRange = CPTPlotRange(location: minYRange! as NSNumber, length: yLength! as NSNumber)
        
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
        plotSpace.globalYRange = plotSpace.yRange
        plotSpace.globalXRange = plotSpace.xRange
        
        
        
        
        //MARK: Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.labelingPolicy              = CPTAxisLabelingPolicy.none
            x.orthogonalPosition          = maxYRange + 4 as NSNumber?
            x.majorTickLineStyle          = nil
            x.minorTickLineStyle          = nil
            x.minorTicksPerInterval       = 10
            x.labelOffset                 = -5.0
            //x.axisConstraints             = CPTConstraints(relativeOffset: 0.0)
            x.labelingOrigin              = 0.0
            x.preferredNumberOfMajorTicks = 3
            x.delegate = self
            
            //MARK: Axis Line Style
            let als         = CPTMutableLineStyle()
            als.lineWidth   = 0.2
            als.lineColor   = CPTColor.gray()
            x.axisLineStyle = als
            
            //MARK: Label Formatter
            let lts          = CPTMutableTextStyle()
            lts.fontSize     = 10.0
            lts.color        = CPTColor(cgColor: UIColor(netHex: 0xCCCCCC).cgColor)
            x.labelTextStyle = lts
            
            var xLabels = [CPTAxisLabel]()
            var xLocations = [NSNumber]()
            
            for (i, e) in chartXData.enumerated() {
                //print(i, e)
                let label = CPTAxisLabel(text: "\(e)", textStyle: x.labelTextStyle)
                label.tickLocation = NSNumber(value: i)
                label.offset = 0.0
                xLabels.append(label)
                xLocations.append(NSNumber(value: i))
            }
            x.axisLabels = Set(xLabels)
            x.majorTickLocations = Set(xLocations)
        }
        
        
        if let y = axisSet.yAxis {
            //MARK: Axis Line Style
            let als         = CPTMutableLineStyle()
            als.lineWidth   = 0.2
            als.lineColor   = CPTColor.gray()
            
            
            y.orthogonalPosition          = minXRange! as NSNumber
            y.labelingPolicy              = CPTAxisLabelingPolicy.automatic
            y.majorTickLineStyle          = nil
            y.minorTickLineStyle          = nil
            y.minorTicksPerInterval       = 10
            y.labelOffset                 = -5.0
            y.axisConstraints             = CPTConstraints(relativeOffset: 0.0)
            y.labelingOrigin              = 0.0
            //y.preferredNumberOfMajorTicks = 2
            y.delegate                    = self
            
            
            
            y.axisLineStyle = nil
            
            //MARK: Label Text Style
            let lts          = CPTMutableTextStyle()
            lts.fontSize     = 10.0
            lts.color        = CPTColor(cgColor: UIColor(netHex: 0xCCCCCC).cgColor)
            
            y.labelTextStyle = lts
            
            //Label Foramatter
            let labelFormatter                         = NumberFormatter()
            labelFormatter.alwaysShowsDecimalSeparator = false
            labelFormatter.maximumFractionDigits       = 1
            labelFormatter.minimumFractionDigits       = 0
            //labelFormatter.locale                      = Locale(identifier: "en_US")
            labelFormatter.positiveSuffix              = "%"
            labelFormatter.numberStyle                 = .decimal
            y.labelFormatter                           = labelFormatter
            
            //Major Grid lines
            let mgl              = CPTMutableLineStyle()
            mgl.lineWidth        = 0.5
            mgl.lineColor        = CPTColor.gray()
            y.majorGridLineStyle = mgl
            //mgl.lineWidth        = 0.1
            //y.minorGridLineStyle = mgl
            
            y.visibleRange       = plotSpace.yRange
        }
        
        
        //MARK: PLOT
        //line graph plot
        let dataSourceLinePlot        = CPTScatterPlot(frame: CGRect.zero)
        dataSourceLinePlot.identifier = "user Investment graph" as NSCoding & NSCopying & NSObjectProtocol
        dataSourceLinePlot.interpolation = CPTScatterPlotInterpolation.curved
        //graph line style
        if let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as? CPTMutableLineStyle {
            lineStyle.lineWidth              = 2.0
            lineStyle.lineColor              = CPTColor(cgColor: UIColor(netHex: 0x6666FF).cgColor)
            dataSourceLinePlot.dataLineStyle = lineStyle
        }
        //print("graph data: \(chartData)")0x666FFF
        dataSourceLinePlot.dataSource   = self
        newGraph.add(dataSourceLinePlot)
        dataSourceLinePlot.allowsEdgeAntialiasing = true
        
        
        let toolTipLineStyle         = CPTMutableLineStyle()
        toolTipLineStyle.lineColor   = CPTColor(cgColor: UIColor(netHex: 0xCCCCCC).cgColor)
        
        toolTipLineStyle.lineWidth   = 1.0
        //toolTipLineStyle.dashPattern = [5]
        
        let iAxis            = CPTXYAxis(frame: CGRect.zero)
        iAxis.title          = nil
        iAxis.labelFormatter = nil
        iAxis.axisLineStyle  = toolTipLineStyle
        
        
        iAxis.coordinate         = CPTCoordinate.Y
        iAxis.plotSpace          = plotSpace
        iAxis.majorTickLineStyle = nil
        iAxis.minorTickLineStyle = nil
        //iAxis.axisLineCapMax   = cap
        iAxis.orthogonalPosition = 0.0
        iAxis.isHidden             = true
        
        axisSet.axes?.append(iAxis)

        
        self.Graph = newGraph
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        var gradientLayer: CAGradientLayer!
        
        gradientLayer       = CAGradientLayer()
        gradientLayer.frame = self.view.frame
        //  0x0000FF
        gradientLayer.colors     = [UIColor(netHex: 0x666FFF).cgColor, UIColor(netHex: 0x000080).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        self.backgroundView.layer.addSublayer(gradientLayer)
    }
    
    //MARK: PLOT DATA SOURCE METHODS
    //Return number of points in a  plot to be
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        //print(UInt(self.chartXData.count))
        return UInt(self.chartXData.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any?
    {
        switch CPTScatterPlotField(rawValue: Int(fieldEnum))! {
        case .X:
           // print(chartXData[Int(idx)])
            return Int(idx)
        case .Y:
            return chartYData[Int(idx)]
        }
    }
    
    //MARK: PLOT SPACE DELEGATE
    
    //Event handling for tool tip
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDownEvent event: UIEvent, at point: CGPoint) -> Bool {
        point1 = space.plotPoint(for: event)
        let index: Double? = round(Double(point1![0]))
        point1![0] = NSNumber(value: index!)
        
        var tooltipPoint = space.plotAreaViewPoint(forPlotPoint: point1!)
        tooltipPoint.x = round(tooltipPoint.x)
        
        var p4 = Graph.convert(tooltipPoint, from: Graph.plotAreaFrame?.plotArea)
        
        if (space as! CPTXYPlotSpace).xRange.contains(index!) == true {
            let range = Graph.plot(at: UInt(0))?.plotRange(for: .X)
            if index! <= Double((range?.location)!) {
                p4.x = graph.bounds.minX + 10
            }
            else if index! >= (Double((range?.location)!) + Double((range?.length)!)) {
                p4.x = graph.bounds.maxX - tooltip.frame.size.width - 20
            }
            
            tooltip.isHidden = false
            returns.isHidden = false
            percentage.isHidden = false
            tooltip.center = CGPoint(x: p4.x + 50.0, y: Graph.bounds.size.height)
            //returns.leadingAnchor.constraint(equalTo: tooltip.layoutMarginsGuide.leadingAnchor)
            
            if index! >= (Double((range?.location)!) + Double((range?.length)!)) {
                returns.frame = CGRect(x: tooltip.frame.minX - 60.0, y: tooltip.frame.minY + 20.0, width: returns.frame.size.width, height: returns.frame.size.height)
                percentage.frame = CGRect(x: tooltip.frame.minX - 20.0, y: tooltip.frame.minY - 20.0, width: percentage.frame.size.width, height: percentage.frame.size.height)
            }
            else  {
                returns.frame = CGRect(x: tooltip.frame.minX, y: tooltip.frame.minY + 20.0, width: returns.frame.size.width, height: returns.frame.size.height)
                percentage.frame = CGRect(x: tooltip.frame.minX, y: tooltip.frame.minY - 20.0, width: percentage.frame.size.width, height: percentage.frame.size.height)
            }
            
            
            tooltip.text = "\(chartYData[Int(index!)])%"
            drawTooltipLine(space: space, date: nil, pointData: index as NSNumber?, hidden: false)
        }
        return true
        
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceDraggedEvent event: UIEvent, at point: CGPoint) -> Bool {
        let res  = plotSpace(space, shouldHandlePointingDeviceDownEvent: event, at : point)
        return res
    }
    
    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceUp event: UIEvent, at point: CGPoint) -> Bool {
        tooltip.isHidden = true
        returns.isHidden = true
        percentage.isHidden = true
        //toolTipArrow.isHidden = true
        drawTooltipLine(space: space, date: nil, pointData: nil, hidden: true)
        return true
    }
    
    
    private func drawTooltipLine(space: CPTPlotSpace, date: Double?, pointData: NSNumber?, hidden: Bool){
        let axisSet = space.graph?.axisSet
        let axes    = axisSet?.axes
        let iAxis   = axes?.last as! CPTXYAxis
        
        if let d = pointData {
            if (space as! CPTXYPlotSpace).xRange.contains(Double(d)) == true {
                iAxis.orthogonalPosition = pointData ?? 0.0
                iAxis.isHidden             = hidden
            }
            else {
                if Double(d) <= (space as! CPTXYPlotSpace).xRange.midPoint as! Double {
                    iAxis.orthogonalPosition = minXRange as NSNumber?
                    iAxis.isHidden = hidden
                    
                }
                else {
                    iAxis.orthogonalPosition = minXRange! + xLength! as NSNumber
                    iAxis.isHidden = hidden
                }
            }
        }
        else {
            iAxis.isHidden = hidden
        }
        
    }
}
