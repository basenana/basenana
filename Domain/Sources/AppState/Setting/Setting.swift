//
//  Setting.swift
//  Domain
//
//  Created by Hypo on 2024/12/11.
//


public class Setting {
    static var global = Setting()
    
    public var general = GeneralSetting()
    public var appearance = AppearanceSetting()
    public var reading = ReadingSetting()
    public var document = DocumentSetting()
    public var database = DatabaseSetting()

    private init(){ }
}
