#subnet Group Creation
resource "aws_db_subnet_group" "default" {
  name       = "custom"
  subnet_ids = [aws_subnet.dbpvt.id, aws_subnet.dbpvt2.id]

  tags = {
    Name = "CustomGroup"
  }
}

#Database instance creation
resource "aws_db_instance" "default" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_name                = "mydb"
  username               = "foo"
  password               = "foobarbaz"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db.id]
}