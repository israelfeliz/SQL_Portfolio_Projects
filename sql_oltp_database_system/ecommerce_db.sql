-- SQL script for an e-commerce database system

CREATE TABLE customers (
    customer_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20) NOT NULL,
    date_of_birth DATE,
    email VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20),

    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city VARCHAR(50) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,

    password_hash TEXT NOT NULL,    
    customer_status VARCHAR(15) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CHECK (customer_status IN ('active', 'inactive', 'locked'))
);

CREATE TABLE categories (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id BIGINT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_parent_category
        FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE products (
    product_id BIGSERIAL PRIMARY KEY,
    product_name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    category_id BIGINT NOT NULL,
    sku VARCHAR(30) UNIQUE NOT NULL,
    brand VARCHAR(50),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),
    reorder_level INT NOT NULL CHECK (reorder_level >= 0),
    weight NUMERIC(10,2),
    dimensions TEXT,
    color VARCHAR(100),
    size VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_category_product
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMERIC(10,2) NOT NULL CHECK(total_amount > 0),
    shipping_address TEXT NOT NULL,
    billing_address TEXT NOT NULL,
    last_update TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(20) NOT NULL
    CHECK (order_status IN ('pending', 'cancelled', 'processing', 
                            'shipped', 'delivered', 'returned')),
 
    CONSTRAINT FK_customer_order 
    FOREIGN KEY (customer_id)
    REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2)NOT NULL CHECK (unit_price > 0),

    CONSTRAINT FK_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id),
    
    CONSTRAINT FK_items_order_product
        FOREIGN KEY (product_id)
        REFERENCES products (product_id)
);

CREATE TABLE payments (
    payment_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT UNIQUE NOT NULL,
    payment_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    payment_amount NUMERIC(10,2)
        NOT NULL
        CHECK (payment_amount > 0),

    payment_method VARCHAR(20)
        NOT NULL
        CHECK (
            payment_method IN (
                'credit card',
                'debit card',
                'paypal',
                'bank transfer',
                'cash',
                'check'
            )
        ),

    payment_status VARCHAR(20)
        NOT NULL
        CHECK (
            payment_status IN (
                'pending',
                'processing',
                'cancelled',
                'completed',
                'failed',
                'partially_refunded',
                'refunded'
            )
        ),

    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    currency VARCHAR(3) NOT NULL,
    payment_provider VARCHAR(20),
    billing_address TEXT NOT NULL,

    refund_amount NUMERIC(10,2)
        CHECK (refund_amount >= 0),

    is_refunded BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_order_payment
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);


CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    customer_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_title VARCHAR(100) NOT NULL,
    review_text TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    helpful_votes INT DEFAULT 0,
    review_status VARCHAR(20) DEFAULT 'pending'
        CHECK (review_status IN ('approved', 'pending', 'rejected')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(product_id, customer_id),

    CONSTRAINT FK_product_review
        FOREIGN KEY (product_id) 
        REFERENCES products (product_id),
    CONSTRAINT FK_customer_review
        FOREIGN KEY (customer_id) 
        REFERENCES customers (customer_id)
);

CREATE TABLE warehouses (
    warehouse_id SERIAL PRIMARY KEY,
    warehouse_name VARCHAR (100) UNIQUE NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50) NOT NULL,  
    country VARCHAR(50) NOT NULL,  
    manager_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory (
    inventory_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity_in_stock INT NOT NULL 
    CHECK (quantity_in_stock >= 0),
    reserved_quantity INT NOT NULL
    CHECK (reserved_quantity >= 0),
    reorder_level INT NOT NULL,
    restock_date DATE,
    last_stock_update DATE,
    inventory_status VARCHAR(20)
        CHECK (inventory_status IN (
            'in_stock',
            'low_stock',
            'out_of_stock',
            'backordered')),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(product_id, warehouse_id),

    CONSTRAINT FK_product_inventory
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),

    CONSTRAINT FK_warehouse_inventory
        FOREIGN KEY (warehouse_id)
        REFERENCES warehouses (warehouse_id)
);

CREATE TABLE shipping (
    shipping_id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL,
    shipping_method VARCHAR(50) NOT NULL,
    tracking_number VARCHAR(100) UNIQUE,
    shipping_status VARCHAR (30) NOT NULL
        CHECK (shipping_status IN (
            'pending',
            'processing',
            'shipped',
            'in_transit',
            'delivered',
            'cancelled',
            'returned')),
    shipping_cost NUMERIC(10, 2) NOT NULL
        CHECK ( shipping_cost >= 0),
    carrier VARCHAR (50),
    shipping_address TEXT NOT NULL,
    estimated_delivery_date DATE,
    actual_delivery_date DATE,
    shipped_date DATE, 
    delivered_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_order_shipping
        FOREIGN KEY (order_id)
        REFERENCES orders (order_id)
);

-- This table should be linked products or other
CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(50),
    email VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    company_name VARCHAR(50) NOT NULL,
    address TEXT NOT NULL UNIQUE,
    city VARCHAR(50),
    country VARCHAR(50),
    postal_code VARCHAR(10),
    website VARCHAR(100),
    tax_id VARCHAR(20) UNIQUE NOT NULL,
    payment_terms VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_suppliers (
    product_supplier_id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL,
    supplier_id BIGINT NOT NULL,
    supplier_price NUMERIC(10, 2) NOT NULL CHECK(supplier_price > 0),
    minimum_order_quantity INT CHECK (minimum_order_quantity > 0),
    lead_time_days INT CHECK (lead_time_days >= 0),
    supplier_sku VARCHAR(20) NOT NULL,
    contract_start_date DATE, 
    contract_end_date DATE CHECK (contract_end_date >= contract_start_date),
    is_primary_supplier BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT FK_supplier_product_supplier
        FOREIGN KEY (supplier_id)
        REFERENCES suppliers (supplier_id),
    
    CONSTRAINT FK_product_product_supplier
        FOREIGN KEY (product_id)
        REFERENCES products (product_id),
    CONSTRAINT UN_product_supplier
        UNIQUE (product_id, supplier_id)
);
