//
//  CategoryEntity.swift
//  Wordbook
//
//  Created by 王杰 on 2019/8/22.
//  Copyright © 2019 Jerry Wong. All rights reserved.
//

import CoreData
import Combine

extension CategoryEntity {
    
    func toCategoryModel() -> CategoryModel {
        return CategoryModel(name: name ?? "Unknown", code: code)
    }
    
    static func newCategory(for name: String) -> AnyPublisher<CategoryModel, Error> {
        return Future { promise in
            let lstCode = getCategories()?.first?.code
            let context = CoreDataManager.shared.managedObjectContext
            let categoryEntity = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as! CategoryEntity
            categoryEntity.name = name
            categoryEntity.code = Int16((lstCode ?? 0) + 1)
            CoreDataManager.shared.saveContext()
            promise(.success(categoryEntity.toCategoryModel()))
        }.eraseToAnyPublisher()
    }
    
    static func getCategories() -> [CategoryModel]? {
           let context = CoreDataManager.shared.managedObjectContext
           let request = NSFetchRequest<CategoryEntity>()
           request.entity = NSEntityDescription.entity(forEntityName: "Category", in: context)
           request.sortDescriptors = [NSSortDescriptor(key: "code", ascending: false)]
           var objs: [CategoryEntity]?
           do {
               objs = try context.fetch(request)
           } catch {
               let nserror = error as NSError
               NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
           }
           
           var result: [CategoryModel] = []
           if objs != nil {
               for note in objs! {
                   result.append(note.toCategoryModel())
               }
           }
           
           return result
       }
    
}
