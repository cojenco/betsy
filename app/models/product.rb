class Product < ApplicationRecord
  has_and_belongs_to_many :categories 
  belongs_to :merchant
  has_many :order_items
  has_many :reviews

  validates :name, presence: true, length: { in: 1..100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :inventory, presence: true, numericality: { only_integer: true }
  validates :price, presence: true, numericality: true
  validates :img_url, presence: true
  validates_associated :categories

  def self.cart_total_items(session)
    total = 0
    item_count = session[:cart].values
    item_count.each do |num|
      total += num.to_i
    end

    return total
  end

  def self.subtotal(session)
    subtotal = 0
    session[:cart].each do |product_id, quant|
      @product = Product.find_by(id: product_id)
      subtotal += @product.price * quant.to_i
    end
    return subtotal
  end

  def self.active_products
    return Product.all.where(active: true)
  end

  def decrease_inventory(quantity)
    self.inventory -= quantity
    self.save
  end
  
  def average_rating
    return 0 if self.reviews.empty?

    average = 0.0
    self.reviews.each do |r|
      average += r.rating
    end
    return (average/self.reviews.count).round(2)
  end

  def add_to_cart(session, quantity)
    if session[:cart][self.id.to_s] 
      session[:cart][self.id.to_s] += quantity 
    else 
      session[:cart][self.id.to_s] = quantity
    end
  end

  def update_quant(session, quantity)
    session[:cart][self.id.to_s] = quantity
  end

  def remove_from_cart(session)
    session[:cart].delete(self.id.to_s)
  end

  def total(quantity)
    return total = self.price * quantity
  end

  def quant_in_cart(session, quantity)
    cart_quant = session[:cart][self.id.to_s]
    if session[:cart][self.id.to_s]
      return cart_quant + quantity <= self.inventory
    else
      return true
    end
  end
end
