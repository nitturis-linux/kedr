struct page *page = alloc_pages(GFP_KERNEL, 1);
if (page)
	__free_pages(page, 1);