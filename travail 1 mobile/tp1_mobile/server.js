const express = require('express');
const fs = require('fs');
const path = require('path');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middlewares
app.use(cors());
app.use(bodyParser.json());

// Chemins vers les fichiers de données
const productsFilePath = path.join(__dirname, 'data', 'products.json');
const ordersFilePath = path.join(__dirname, 'data', 'orders.json');

// Assurez-vous que le répertoire data existe
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir);
}

// Création des fichiers de données s'ils n'existent pas
if (!fs.existsSync(productsFilePath)) {
    fs.writeFileSync(productsFilePath, JSON.stringify([], null, 2));
}

if (!fs.existsSync(ordersFilePath)) {
    fs.writeFileSync(ordersFilePath, JSON.stringify([], null, 2));
}

// Fonctions utilitaires pour lire et écrire les données
const readProducts = () => {
    const data = fs.readFileSync(productsFilePath, 'utf8');
    return JSON.parse(data);
};

const writeProducts = (products) => {
    fs.writeFileSync(productsFilePath, JSON.stringify(products, null, 2));
};

const readOrders = () => {
    const data = fs.readFileSync(ordersFilePath, 'utf8');
    return JSON.parse(data);
};

const writeOrders = (orders) => {
    fs.writeFileSync(ordersFilePath, JSON.stringify(orders, null, 2));
};

// Routes pour les produits
app.get('/api/products', (req, res) => {
    try {
        const products = readProducts();
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: 'Erreur lors de la récupération des produits' });
    }
});

app.post('/api/products', (req, res) => {
    try {
        const products = readProducts();
        const newProduct = {
            id: products.length > 0 ? Math.max(...products.map(p => p.id)) + 1 : 1,
            name: req.body.name,
            price: req.body.price,
            description: req.body.description,
            createdAt: new Date().toISOString()
        };
        
        products.push(newProduct);
        writeProducts(products);
        
        res.status(201).json(newProduct);
    } catch (error) {
        res.status(500).json({ error: 'Erreur lors de l\'ajout du produit' });
    }
});

// Routes pour les commandes
app.get('/api/orders', (req, res) => {
    try {
        const orders = readOrders();
        res.json(orders);
    } catch (error) {
        res.status(500).json({ error: 'Erreur lors de la récupération des commandes' });
    }
});

app.post('/api/orders', (req, res) => {
    try {
        const orders = readOrders();
        const products = readProducts();
        
        // Vérification que les produits commandés existent
        const orderItems = req.body.items || [];
        for (const item of orderItems) {
            const product = products.find(p => p.id === item.productId);
            if (!product) {
                return res.status(400).json({ error: `Le produit avec l'ID ${item.productId} n'existe pas` });
            }
        }
        
        const newOrder = {
            id: orders.length > 0 ? Math.max(...orders.map(o => o.id)) + 1 : 1,
            customerName: req.body.customerName,
            items: orderItems,
            totalAmount: req.body.totalAmount,
            status: 'pending',
            createdAt: new Date().toISOString()
        };
        
        orders.push(newOrder);
        writeOrders(orders);
        
        res.status(201).json(newOrder);
    } catch (error) {
        res.status(500).json({ error: 'Erreur lors de la création de la commande' });
    }
});

// Démarrage du serveur
app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
});