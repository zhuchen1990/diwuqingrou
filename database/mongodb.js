/*插入数据*/
db.users.insertOne({username: "diwuqingrou", password: "root", age: 18, email: "291394199@qq.com", city: "china"});
db.users.insertOne({
    username: "alan",
    password: "123456",
    age: 24,
    email: "291394199@qq.com",
    desc: "my first time is happy!"
});

/*查询所有记录的username,emai*/
db.users.find({}).projection('username,email,_id').sort({_id: -1}).limit(20);

/*查询age>18的记录,并且只查询name,city,email*/
db.users.find({age: {$gt: 18}}, {name: 1, city: 1, email: 1}).limit(5);

/*更新*/
db.users.updateMany({age: {$lt: 18}}, {$set: {status: "reject"}});

/*删除*/
db.users.deleteMany({status: "reject"});