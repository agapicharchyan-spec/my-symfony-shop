<?php

namespace App\Controller;

use App\Repository\ProductRepository;
use App\Repository\CategoryRepository;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Exception;

class HomeController extends AbstractController
{
    #[Route('/', name: 'app_home')]
    public function index(ProductRepository $productRepository, CategoryRepository $categoryRepository): Response
    {
        $products = $productRepository->findAll();
        $categories = $categoryRepository->findAll();

        // Կանխում ենք ջնջված կատեգորիաների սխալը գլխավոր էջում
        foreach ($products as $product) {
            try {
                if ($product->getCategory()) {
                    $product->getCategory()->getName(); // Փորձում ենք կարդալ անունը
                }
            } catch (Exception $e) {
                // Եթե կատեգորիան բազայում չկա, կապը ժամանակավոր դարձնում ենք null
                $product->setCategory(null);
            }
        }

        return $this->render('home/index.html.twig', [
            'products' => $products,
            'categories' => $categories,
            'currentCategory' => null,
        ]);
    }
}