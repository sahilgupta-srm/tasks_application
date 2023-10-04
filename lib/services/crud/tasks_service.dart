import 'dart:async';

import 'package:firstflutternotes/services/crud/crud_exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' ;
import 'package:path/path.dart' show join;


class TasksService{
  Database? _db;
  List<DataBaseTasks> _tasks=[];
  //singleton created so multiple instances do not open
  static final TasksService _shared=TasksService._sharedInstance();
  TasksService._sharedInstance(){
    _taskStreamController=StreamController<List<DataBaseTasks>>.broadcast(
      onListen: (){
        _taskStreamController.sink.add(_tasks);
      }
    );
  }
  factory TasksService()=> _shared;

  late final StreamController<List<DataBaseTasks>> _taskStreamController;
  Stream<List<DataBaseTasks>> get allTasks=>_taskStreamController.stream;

  Future<void> _cachetasks() async{
    final _alltasks=await getAllTasks();
    _tasks=_alltasks.toList();
    _taskStreamController.add(_tasks);
  }

  Future<DataBaseUser> getOrCreateUser({required String email}) async{
    try{
      final user=await getUser(email:email);
      return user;

    }on CouldNotFindUser{
      final createdUser=await createUser(email: email);
      return createdUser;
    }catch (e){
      rethrow;
    }
  }

  Future<DataBaseTasks> updateTasks({required DataBaseTasks task,required String text}) async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    await getTask(id: task.id);

    final updatesCount=await db.update(taskTable, {
      textColumn:text,
      isSyncedWithCloudColumn:0,
    });
    if(updatesCount==0){
      throw CouldNotUpdateTask();
    }
    else{
      final updatedtask= await getTask(id: task.id);
      _tasks.removeWhere((task) => task.id==updatedtask.id);
      _tasks.add(updatedtask);
      _taskStreamController.add(_tasks);
      return updatedtask;

    }
  }

  Future<Iterable<DataBaseTasks>> getAllTasks() async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final tasks=await db.query(taskTable);
    return tasks.map((taskrow)=>DataBaseTasks.fromRow(taskrow));
  }

  Future<DataBaseTasks> getTask({required int id}) async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final task=await db.query(taskTable,limit:1,where:'id=?',whereArgs: [id]);
    if(task.isEmpty){
      throw CouldNotFindNTask();
    }
    else{
      final tasks= DataBaseTasks.fromRow(task.first);
      _tasks.removeWhere((task) => task.id==id);
      _tasks.add(tasks);
      _taskStreamController.add(_tasks);
      return tasks;
    }
  }

  Future<int> deleteAllTasks() async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final numberofDeletions= await db.delete(taskTable);
    _tasks=[];
    _taskStreamController.add(_tasks);
    return numberofDeletions;



  }

   Future<void> deleteTask({required int id}) async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final deletedCount=await db.delete(taskTable,where :'id=?',whereArgs:[id]);
    if(deletedCount==0){
      throw CouldNotDeleteTask();
    }
    else{
      _tasks.removeWhere((task)=>task.id==id);
      _taskStreamController.add(_tasks);
    }
  }

  Future<DataBaseTasks> createTask({required DataBaseUser owner}) async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final dbUser=await getUser(email: owner.email);
    //to make sure owner exists in db
    if(dbUser!=owner){
      throw CouldNotFindUser();
    }
    const text='';
    final taskId=await db.insert(taskTable, {
      userIdColumn:owner.id,
      textColumn:text,
      isSyncedWithCloudColumn:1
    });

    final task=DataBaseTasks(id: taskId, userId: owner.id, text: text, isSyncedWithCloud: true);
    _tasks.add(task);
    _taskStreamController.add(_tasks);
    return task;
  }

  Future<void> deleteUser({required String email}) async{
    await _ensureDbIsOpen();
    final db=_getDatabaseOrThrow();
    final deletedCount=await db.delete(userTable,where :'email=?',whereArgs:[email.toLowerCase()]);
    if(deletedCount!=1){
      throw CouldNotDeleteUser();
    }
  }

Future<DataBaseUser> createUser({required String email}) async{
  await _ensureDbIsOpen();
  final db=_getDatabaseOrThrow();
  final results=await db.query(userTable,limit:1,where:'email=?',whereArgs: [email.toLowerCase()],);
  if(results.isNotEmpty){
    throw UserAlreadyExists();
  }
  final userId=await db.insert(userTable, {emailColumn:email.toLowerCase()});
  return DataBaseUser(id: userId, email: email);
}

Future<DataBaseUser> getUser({required String email}) async{
  await _ensureDbIsOpen();
  final db=_getDatabaseOrThrow();
  final results=await db.query(
    userTable,
    limit:1,
    where:'email=?',
    whereArgs: [email.toLowerCase()]
  );
  if(results.isEmpty){
    throw CouldNotFindUser();
  }
  else{
    return DataBaseUser.fromRow(results.first);
  }
}

  Database _getDatabaseOrThrow(){
    final db=_db;
    if(db==null){
      throw DatabaseIsNotOpen();
    }
    else{
      return db;
    }
   }
  
  Future<void> _ensureDbIsOpen() async{
    try{
      await open();
    }on DatabaseAlreadyOpenException{
      //blank
    }
  }

  Future<void> open() async{
    if(_db!=null){
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docspath=await getApplicationDocumentsDirectory();
      final dbpath=join(docspath.path,dbName);
      final db=await openDatabase(dbpath);
      _db=db;

      
await db.execute(createUserTable);

await db.execute(createTaskTable);
await _cachetasks();
    }on MissingPlatformDirectoryException{
      throw UnabletoGetDocumentsDirectory();
    }

  }
  
  Future<void> close() async{
    final db=_db;
    if (db== null){
      throw DatabaseIsNotOpen();
    }
    else{
      await db.close();
      _db=null;
    }

  }
}



@immutable
class DataBaseUser{
  final int id;
  final String email;

  const DataBaseUser({required this.id, required this.email});

  DataBaseUser.fromRow(Map<String, Object?> map) 
  : id = map[idColumn]as int,
  email= map[emailColumn] as String;

  @override
    String toString()=>'Person,ID=$id,emaill=$email';
  

  @override bool operator ==(covariant DataBaseUser other)=> id==other.id;
  
  @override
  int get hashCode => id.hashCode;
  

}

class DataBaseTasks{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseTasks({required this.id, required this.userId, required this.text, required this.isSyncedWithCloud});

  DataBaseTasks.fromRow(Map<String,Object?> map):
  id=map[idColumn] as int,
  userId=map[userIdColumn] as int,
  text=map[textColumn]as String,
  isSyncedWithCloud=(map[isSyncedWithCloudColumn]as int)==1?true:false;

  @override
  String toString() => 'Task,ID=$id,userId=$userId,isSynchedWithCLoud=$isSyncedWithCloud text=$text';

  @override bool operator ==(covariant DataBaseTasks other)=> id==other.id;
  
  @override
  int get hashCode => id.hashCode;


}
const dbName='tasks.db';
const taskTable='task';
const userTable='user';
const idColumn='id';
const emailColumn='email';
const userIdColumn='user_id';
const textColumn='text';
const isSyncedWithCloudColumn='is_synched_with_cloud';
const createUserTable='''CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);''';
const createTaskTable='''CREATE TABLE IF NOT EXISTS "task" (
	"id"	INTEGER NOT NULL ,
	"user_id"	INTEGER NOT NULL ,
	"text"	TEXT,
	"is_synched_with_cloud" 	INTEGER NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("user_id") REFERENCES "user"("id")
);''';

