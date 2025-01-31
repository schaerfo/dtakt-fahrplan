CREATE VIEW "train_with_part" AS
  select
    train.id,
    train.dtakt_id,
    train.description,
    train.train_number,
    train.line_name,
    train.group_id,
    train_part.id as train_part_id,
    train_part.category_id
  from train
  full outer join train_part on train.train_part_id = train_part.id
;

CREATE VIEW "passenger_train_with_part" AS
  select
    train_with_part.*
  from train_with_part
  join category on train_with_part.category_id = category.id
  where
    substr(category.code, 1, 1) != 'G'
;
