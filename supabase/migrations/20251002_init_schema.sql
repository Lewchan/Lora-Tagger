/*
  # 初始化Lora-Tagger数据库架构

  1. 新建表
    - `images`
      - `id` (uuid, 主键)
      - `user_id` (uuid, 外键到auth.users)
      - `filename` (text, 文件名)
      - `file_path` (text, 文件路径)
      - `file_size` (bigint, 文件大小)
      - `image_type` (text, 图片类型: 'heightmap' 或 'portrait')
      - `width` (integer, 图片宽度)
      - `height` (integer, 图片高度)
      - `uploaded_at` (timestamptz, 上传时间)
      - `updated_at` (timestamptz, 更新时间)

    - `tags`
      - `id` (uuid, 主键)
      - `image_id` (uuid, 外键到images)
      - `tag_name` (text, 标签名称)
      - `tag_value` (text, 标签值)
      - `tag_category` (text, 标签分类)
      - `created_at` (timestamptz, 创建时间)

    - `presets`
      - `id` (uuid, 主键)
      - `user_id` (uuid, 外键到auth.users)
      - `preset_name` (text, 预设名称)
      - `preset_type` (text, 预设类型)
      - `tags_data` (jsonb, 标签数据)
      - `created_at` (timestamptz, 创建时间)

  2. 安全性
    - 为所有表启用RLS
    - 为认证用户添加访问策略
*/

-- 创建images表
CREATE TABLE IF NOT EXISTS images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  filename text NOT NULL,
  file_path text NOT NULL,
  file_size bigint DEFAULT 0,
  image_type text NOT NULL CHECK (image_type IN ('heightmap', 'portrait')),
  width integer DEFAULT 0,
  height integer DEFAULT 0,
  uploaded_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- 创建tags表
CREATE TABLE IF NOT EXISTS tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  image_id uuid REFERENCES images(id) ON DELETE CASCADE NOT NULL,
  tag_name text NOT NULL,
  tag_value text DEFAULT '',
  tag_category text DEFAULT 'general',
  created_at timestamptz DEFAULT now()
);

-- 创建presets表
CREATE TABLE IF NOT EXISTS presets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  preset_name text NOT NULL,
  preset_type text NOT NULL CHECK (preset_type IN ('heightmap', 'portrait')),
  tags_data jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_images_user_id ON images(user_id);
CREATE INDEX IF NOT EXISTS idx_images_type ON images(image_type);
CREATE INDEX IF NOT EXISTS idx_tags_image_id ON tags(image_id);
CREATE INDEX IF NOT EXISTS idx_presets_user_id ON presets(user_id);

-- 启用RLS
ALTER TABLE images ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE presets ENABLE ROW LEVEL SECURITY;

-- Images表策略
CREATE POLICY "用户可以查看自己的图片"
  ON images FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "用户可以上传图片"
  ON images FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户可以更新自己的图片"
  ON images FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户可以删除自己的图片"
  ON images FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);

-- Tags表策略
CREATE POLICY "用户可以查看自己图片的标签"
  ON tags FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM images
      WHERE images.id = tags.image_id
      AND images.user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以为自己的图片添加标签"
  ON tags FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM images
      WHERE images.id = tags.image_id
      AND images.user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以更新自己图片的标签"
  ON tags FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM images
      WHERE images.id = tags.image_id
      AND images.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM images
      WHERE images.id = tags.image_id
      AND images.user_id = auth.uid()
    )
  );

CREATE POLICY "用户可以删除自己图片的标签"
  ON tags FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM images
      WHERE images.id = tags.image_id
      AND images.user_id = auth.uid()
    )
  );

-- Presets表策略
CREATE POLICY "用户可以查看自己的预设"
  ON presets FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "用户可以创建预设"
  ON presets FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户可以更新自己的预设"
  ON presets FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "用户可以删除自己的预设"
  ON presets FOR DELETE
  TO authenticated
  USING (auth.uid() = user_id);
